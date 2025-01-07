// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CATTON is ERC20Burnable {
    uint256 public constant MAX_SUPPLY = 10_000_000_000_000 * 1e9;

    constructor() ERC20("Catton AI", "CATTON") {
        _mint(_msgSender(), MAX_SUPPLY);
    }

    function decimals() public pure override returns (uint8) {
        return 9;
    }
}
