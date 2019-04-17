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
    uint public totalSupply;

    function mint(address,uint) public;
}

contract Ceiling {
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1; }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    // --- Data ---
    MintLike public tkn;
    uint public     roof;

    constructor(address tkn_, uint roof_) public {
        wards[msg.sender] = 1;
        tkn = MintLike(tkn_);
        roof = roof_;
    }

    // --- Ceiling ---
    function mint(address usr, uint wad) public auth {
        require(tkn.totalSupply+wad <= roof)
        tkn.mint(usr, wad);
    }
}
