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

pragma solidity >=0.4.24;

import './lib.sol';
import './medallion.sol';
import './ceiling.sol';
import './budget.sol';

// MedallionFab deploys an ERC20 token, an instance of Ceiling and Budget 
// removing the deployer address from the wards of the Medallion and Ceiling 
// contracts.
//
// By doing the entire deploy in one transaction, we can simplify auditing of 
// the deploy and ensure that no ward was added to any of the Medallion and
// Ceiling contract other than the Budget ward.
//
contract MedallionFab {
    Medallion public mdln;
    Ceiling public   ceil;
    Budget public    bags;

    constructor (uint roof, address ward) public {
        address self = address(this);
        mdln = new Medallion("MDLN", "Centrifuge Medallion", "1", 0); // TODO: chainid/memory
        ceil = new Ceiling(address(mdln), roof);
        bags = new Budget(address(ceil));
        
        mdln.rely(address(ceil));
        mdln.deny(self);
        ceil.rely(address(bags));
        ceil.deny(self);
        bags.rely(ward);
        bags.deny(self);
    }
}

