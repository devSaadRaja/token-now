// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "forge-std/Test.sol";
// import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    // Counter public counter;

    function setUp() public {
        // counter = new Counter();
        // counter.setNumber(0);
    }

    // function test_Increment() public {
    //     counter.increment();
    //     console.log(counter.number());
    //     assertEq(counter.number(), 1);
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     console.log(counter.number());
    //     assertEq(counter.number(), x);
    // }
}
