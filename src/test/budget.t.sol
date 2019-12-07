// Copyright (C) 2019 lucasvo

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.5.12;

import "ds-test/test.sol";

import "../budget.sol";
import "../lib.sol";

contract MockMint {
    uint public count;
    uint public totalSupply;

    address[] public usrs;
    uint[] public    wads;

    function setSupply(uint sup) public {
        totalSupply = sup;
    }

    function mint(address usr, uint wad) public {
        usrs.push(usr);
        wads.push(wad);
        count = count+1;
    }
}

contract User {
    function doMint(address budget, address usr, uint wad) public {
        MintLike(budget).mint(usr, wad);
    }
}

contract BudgetTest is DSTest  {
    Budget   bag;
    MockMint minter;
    address  self;
    User     user1;
    User     user2;

    function setUp() public {
        minter = new MockMint();
        self = address(this);
        user1 = new User();
        user2 = new User();
    }

    function createBag ()
        internal
        returns (Budget)
    {
        return new Budget(address(minter));
    }

    function testMint() public logs_gas {
        bag = createBag();
        bag.budget(address(user1), 10);
        bag.budget(address(user2), 10);
        user1.doMint(address(bag), self, 10);
        user2.doMint(address(bag), self, 10);
        assertEq(minter.count(), 2);
        assertEq(minter.wads(0), 10);
        assertEq(minter.usrs(0), self);
    }

    function testFailOverBudgetMint() public logs_gas {
        bag = createBag();
        bag.budget(address(user1), 10);
        user1.doMint(address(bag), self, 30);
    }

    function testFailOverBudgetMultipleMint() public logs_gas {
        bag = createBag();
        bag.budget(address(user1), 10);
        user1.doMint(address(bag), self, 5);
        user1.doMint(address(bag), self, 5);
        user1.doMint(address(bag), self, 5);
    }

    function testFailMint() public logs_gas {
        bag = createBag();
        user1.doMint(address(bag), self, 10);
    }
}
