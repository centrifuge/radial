/// radial.t.sol

// Copyright (C) 2015-2019  DappHub, LLC,
// Copyright (C) 2019 lucasvo

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity 0.5.10;

import "ds-test/test.sol";

import "../radial.sol";

contract RadialUser {
    Radial  radial;

    constructor(Radial radial_) public {
        radial = radial_;
    }

    function doTransferFrom(address from, address to, uint amount)
        public
        returns (bool)
    {
        return radial.transferFrom(from, to, amount);
    }

    function doTransfer(address to, uint amount)
        public
        returns (bool)
    {
        return radial.transfer(to, amount);
    }

    function doApprove(address recipient, uint amount)
        public
        returns (bool)
    {
        return radial.approve(recipient, amount);
    }

    function doAllowance(address owner, address spender)
        public
        view
        returns (uint)
    {
        return radial.allowance(owner, spender);
    }

    function doBalanceOf(address who) public view returns (uint) {
        return radial.balanceOf(who);
    }

    function doApprove(address usr)
        public
        returns (bool)
    {
        return radial.approve(usr, uint(-1));
    }
    function doMint(uint wad) public {
        radial.mint(address(this), wad);
    }
    function doBurn(uint wad) public {
        radial.burn(address(this), wad);
    }
    function doMint(address usr, uint wad) public {
        radial.mint(usr, wad);
    }
    function doBurn(address usr, uint wad) public {
        radial.burn(usr, wad);
    }

}

contract Hevm {
    function warp(uint256) public;
}

contract RadialTest is DSTest {
    uint constant initialBalanceThis = 1000;
    uint constant initialBalanceCal = 100;

    Hevm hevm;
    Radial radial;
    address user1;
    address user2;
    address self;


    uint amount = 2;
    uint fee = 1;
    uint nonce = 0;
    uint deadline = 0;
    address cal = 0x78Df63f83d8CFfaeB2f5522102113a4Cb44bD857;
    address del = 0xc351B89C286288B9201835f78dbbccaDA357671e;
    bytes32 r = 0x33e75ec358ed0bb00057fbc7fa96a83abe26acbd0fbe93d05e652f17a5424df4;
    bytes32 s = 0x0b708d5abfb8efbe26b3a6a217faa7a5ff146641a9a66686f1a8603ee0bfd08a;
    uint8 v = 28;
    bytes32 _r = 0xf2d069ada54f7a6d2e162611b772749e827378352de614e687e11152dad0c373;
    bytes32 _s = 0x1b3582502f3b5d4a9aed712a148d14f71be757336189c4fc722d2473fd4aad9f;
    uint8 _v = 28;

    function setUp() public {
        hevm = Hevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        hevm.warp(604411200);
        radial = createRadial();
        radial.mint(address(this), initialBalanceThis);
        radial.mint(cal, initialBalanceCal);
        user1 = address(new RadialUser(radial));
        user2 = address(new RadialUser(radial));
        self = address(this);
    }

    function createRadial() internal returns (Radial) {
        return new Radial(1);
    }

    function testSetupPrecondition() public {
        assertEq(radial.balanceOf(self), initialBalanceThis);
    }

    function testTransferCost() public logs_gas {
        radial.transfer(address(0), 10);
    }

    function testAllowanceStartsAtZero() public logs_gas {
        assertEq(radial.allowance(user1, user2), 0);
    }

    function testValidTransfers() public logs_gas {
        uint sentAmount = 250;
        emit log_named_address("radial11111", address(radial));
        radial.transfer(user2, sentAmount);
        assertEq(radial.balanceOf(user2), sentAmount);
        assertEq(radial.balanceOf(self), initialBalanceThis - sentAmount);
    }

    function testFailWrongAccountTransfers() public logs_gas {
        uint sentAmount = 250;
        radial.transferFrom(user2, self, sentAmount);
    }

    function testFailInsufficientFundsTransfers() public logs_gas {
        uint sentAmount = 250;
        radial.transfer(user1, initialBalanceThis - sentAmount);
        radial.transfer(user2, sentAmount + 1);
    }

    function testApproveSetsAllowance() public logs_gas {
        emit log_named_address("Test", self);
        emit log_named_address("radial", address(radial));
        emit log_named_address("Me", self);
        emit log_named_address("User 2", user2);
        radial.approve(user2, 25);
        assertEq(radial.allowance(self, user2), 25);
    }

    function testChargesAmountApproved() public logs_gas {
        uint amountApproved = 20;
        radial.approve(user2, amountApproved);
        assertTrue(RadialUser(user2).doTransferFrom(self, user2, amountApproved));
        assertEq(radial.balanceOf(self), initialBalanceThis - amountApproved);
    }

    function testFailTransferWithoutApproval() public logs_gas {
        radial.transfer(user1, 50);
        radial.transferFrom(user1, self, 1);
    }

    function testFailChargeMoreThanApproved() public logs_gas {
        radial.transfer(user1, 50);
        RadialUser(user1).doApprove(self, 20);
        radial.transferFrom(user1, self, 21);
    }
    function testTransferFromSelf() public {
        radial.transferFrom(self, user1, 50);
        assertEq(radial.balanceOf(user1), 50);
    }
    function testFailTransferFromSelfNonArbitrarySize() public {
        // you shouldn't be able to evade balance checks by transferring
        // to yourself
        radial.transferFrom(self, self, radial.balanceOf(self) + 1);
    }
    function testMintself() public {
        uint mintAmount = 10;
        radial.mint(address(this), mintAmount);
        assertEq(radial.balanceOf(self), initialBalanceThis + mintAmount);
    }
    function testMintUser() public {
        uint mintAmount = 10;
        radial.mint(user1, mintAmount);
        assertEq(radial.balanceOf(user1), mintAmount);
    }
    function testFailMintUserNoAuth() public {
        RadialUser(user1).doMint(user2, 10);
    }
    function testMintUserAuth() public {
        radial.rely(user1);
        RadialUser(user1).doMint(user2, 10);
    }

    function testBurn() public {
        uint burnAmount = 10;
        radial.burn(address(this), burnAmount);
        assertEq(radial.totalSupply(), initialBalanceThis + initialBalanceCal - burnAmount);
    }
    function testBurnself() public {
        uint burnAmount = 10;
        radial.burn(address(this), burnAmount);
        assertEq(radial.balanceOf(self), initialBalanceThis - burnAmount);
    }
    function testBurnUserWithTrust() public {
        uint burnAmount = 10;
        radial.transfer(user1, burnAmount);
        assertEq(radial.balanceOf(user1), burnAmount);

        RadialUser(user1).doApprove(self);
        radial.burn(user1, burnAmount);
        assertEq(radial.balanceOf(user1), 0);
    }
    function testBurnAuth() public {
        radial.transfer(user1, 10);
        radial.rely(user1);
        RadialUser(user1).doBurn(10);
    }
    function testBurnUserAuth() public {
        radial.transfer(user2, 10);
        RadialUser(user2).doApprove(user1);
        RadialUser(user1).doBurn(user2, 10);
    }

    function testFailUntrustedTransferFrom() public {
        assertEq(radial.allowance(self, user2), 0);
        RadialUser(user1).doTransferFrom(self, user2, 200);
    }
    function testTrusting() public {
        assertEq(radial.allowance(self, user2), 0);
        radial.approve(user2, uint(-1));
        assertEq(radial.allowance(self, user2), uint(-1));
        radial.approve(user2, 0);
        assertEq(radial.allowance(self, user2), 0);
    }
    function testTrustedTransferFrom() public {
        radial.approve(user1, uint(-1));
        RadialUser(user1).doTransferFrom(self, user2, 200);
        assertEq(radial.balanceOf(user2), 200);
    }
    function testApproveWillModifyAllowance() public {
        assertEq(radial.allowance(self, user1), 0);
        assertEq(radial.balanceOf(user1), 0);
        radial.approve(user1, 1000);
        assertEq(radial.allowance(self, user1), 1000);
        RadialUser(user1).doTransferFrom(self, user1, 500);
        assertEq(radial.balanceOf(user1), 500);
        assertEq(radial.allowance(self, user1), 500);
    }
    function testApproveWillNotModifyAllowance() public {
        assertEq(radial.allowance(self, user1), 0);
        assertEq(radial.balanceOf(user1), 0);
        radial.approve(user1, uint(-1));
        assertEq(radial.allowance(self, user1), uint(-1));
        RadialUser(user1).doTransferFrom(self, user1, 1000);
        assertEq(radial.balanceOf(user1), 1000);
        assertEq(radial.allowance(self, user1), uint(-1));
    }

    function testRadialAddress() public {
        assertEq(address(radial), address(0x0F1c6673615352379AFC1a60e3D0234101D67eb2));
    }

    function testTypehash() public {
        assertEq(radial.PERMIT_TYPEHASH(), 0xea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb);
    }

    function testDomain_Separator() public {
        assertEq(radial.DOMAIN_SEPARATOR(), 0xafcac80a03e5119639bb0f77f7aa754ac902dbfa79074a8de9e50aea7ee83b6a);
    }

    function testPermit() public {
        assertEq(radial.nonces(cal), 0);
        assertEq(radial.allowance(cal, del), 0);
        radial.permit(cal, del, 0, 0, true, v, r, s);
        assertEq(radial.allowance(cal, del),uint(-1));
        assertEq(radial.nonces(cal),1);
    }

    function testFailPermitAddress0() public {
        _v = 0;
        radial.permit(address(0), del, 0, 0, true, v, r, s);
    }

    function testPermitWithExpiry() public {
        assertEq(now, 604411200);
        radial.permit(cal, del, 0, 604411200 + 1 hours, true, _v, _r, _s);
        assertEq(radial.allowance(cal, del),uint(-1));
        assertEq(radial.nonces(cal),1);
    }

    function testFailPermitWithExpiry() public {
        hevm.warp(now + 2 hours);
        assertEq(now, 604411200 + 2 hours);
        radial.permit(cal, del, 0, 1, true, _v, _r, _s);
    }

    function testFailReplay() public {
        radial.permit(cal, del, 0, 0, true, v, r, s);
        radial.permit(cal, del, 0, 0, true, v, r, s);
    }
}
