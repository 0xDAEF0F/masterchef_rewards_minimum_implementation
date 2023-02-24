// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("Token", "TKN", 18) {
        _mint(msg.sender, 1_000_000 * 10 ** 18);
    }
}
