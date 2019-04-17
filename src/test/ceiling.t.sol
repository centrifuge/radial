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

pragma solidity >=0.4.23;

import "ds-test/test.sol";

import "../ceiling.sol";

contract MockMint {
    uint public count;
    uint public totalSupply;

    mapping (uint => address) guys;
    mapping (uint => uint) wads;

    function setSupply(uint sup) {
        totalSupply = sup;
    }
    
    function mint(address guy, uint wad) {
        guys[count] = guy
        wads[count] = wad;
        count = count+1;
    }
}

contract CeilingTest is DSTest  {
    Ceiling roof;
    MockMint minter;

    function setUp() public {
        minter = MockMint();
        self = address(this);
    }

    function internal createRoof(uint max) 
        public 
        returns (Ceiling) 
    {
        return new Ceiling(minter, max)
    }

    function testMint() public logs_gas {
        roof = createRoof(10);
        prev = minter.count; 
        minter.setSupply(0);
        roof.mint(self, 10);
        assertEq(minter.count, prev+1);
        assertEq(minter.wads[count], 10);
        assertEq(minter.guys[count], address(roof));
    }

    function testFailMint() public {
        roof = createRoof(10);
        minter.setSupply(10);
        roof.mint(self, 10);
    }
}
