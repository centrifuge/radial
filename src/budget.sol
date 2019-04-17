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

contract MintLike {
    function mint(address,uint) public;
}

contract Budget {
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1; }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    // --- Data ---
    MintLike                  public roof;
    mapping (address => uint) public budget;

    constructor(address roof_) public {
        wards[msg.sender] = 1;
        roof = MintLike(roof_);
    }

    // --- Budget ---
    function mint(address usr, uint wad) public {
        require(budget[msg.sender] >= wad);
        budget[msg.sender] -= wad;
        roof.mint(usr, wad);
    }
    function budget(address usr, uint wad) public auth {
        budget[usr] = wad;
    }
}
