// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract Counter {
    // ==================== STRUCTURE ==================== //

    uint256 public number;

    // ==================== EVENTS ==================== //

    // ==================== MODIFIERS ==================== //

    // ==================== FUNCTIONS ==================== //

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
