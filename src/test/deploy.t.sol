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

pragma solidity 0.5.10;

import "ds-test/test.sol";

import "../deploy.sol";
import "../budget.sol";
import "../radial.sol";

contract Ward {
  function rely(address) public {}
  function deny(address) public {}
}

contract RadialUser {
    Budget budget;
    function file(address _budget) public {
        budget = Budget(_budget);
    }

    function doRely(address dst, address usr) public {
        Ward(dst).rely(usr);
    }

    function doDeny(address dst, address usr) public {
        Ward(dst).deny(usr);
    }

    function doBudget(address usr, uint wad) public {
        budget.budget(usr, wad);
    }
}



contract DeployTest is DSTest  {
    address self;
    RadialUser usr;

    function setUp() public{
        self = address(this);
        usr = new RadialUser();
        super.setUp();
    }

    function testDeploy() public logs_gas {
        RadialFab     depl = new RadialFab(100, address(usr), 99);
        Radial        tkn  = depl.tkn();
        Budget        bags = depl.bags();

        usr.file(address(depl.bags()));
        usr.doBudget(self, 10);

        bags.mint(self, 10);
        assertEq(tkn.balanceOf(self), 10);
        assertEq(tkn.totalSupply(), 10);
    }

    function testFailDeploySelf() public {
        RadialFab     depl = new RadialFab(100, address(usr), 99);
        Budget        bags = depl.bags();
        bags.budget(self, 10);
    }

    function testFailDeployBreakCeiling() public {
        RadialFab     depl = new RadialFab(100, self, 99);
        Budget        bags = depl.bags();
        bags.budget(self, 200);
        bags.mint(self, 200);
    }

    function testFailDeployCallCeiling() public {
        RadialFab     depl = new RadialFab(100, self, 99);
        Ceiling       ceil = depl.ceil();
        ceil.mint(self, 10);
    }

    function testFailDeployCallRadial() public {
        RadialFab     depl = new RadialFab(100, self, 99);
        Radial        tkn  = depl.tkn();
        tkn.mint(self, 10);
    }

    function testFailDeployNoBudget() public {
        RadialFab  depl = new RadialFab(100, self, 99);
        Budget bags     = depl.bags();

        bags.budget(self, 10);
        bags.mint(self, 20);
    }
}
