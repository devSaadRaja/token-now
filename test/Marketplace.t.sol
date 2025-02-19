// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {RealEstateToken} from "../src/RealEstateToken.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract MarketplaceTest is Test {
    address public owner = vm.addr(1);
    address public seller = vm.addr(2);
    address public buyer = vm.addr(3);

    RealEstateToken public token;
    Marketplace public marketplace;

    bytes data = "";

    function setUp() public {
        deal(owner, 10 ether);
        deal(seller, 10 ether);
        deal(buyer, 10 ether);

        vm.startPrank(owner); // OWNER
        token = new RealEstateToken(
            owner,
            "",
            "https://gateway.pinata.cloud/ipfs/"
        );
        marketplace = new Marketplace();
        vm.stopPrank(); // OWNER

        vm.startPrank(seller);
        token.mint(
            seller,
            "p",
            0,
            10,
            "QmdAcTQR8R5f23Rx4WeKg9WiK935QnsBYxPJawnJ3W7Hyd",
            data
        );
        // token.mint(
        //     seller,
        //     "f",
        //     10001,
        //     10,
        //     "QmdAcTQR8R5f23Rx4WeKg9WiK935QnsBYxPJawnJ3W7Hyd",
        //     data
        // );
        vm.stopPrank();
    }

    function testCreateOrderNonEscrowed() public {
        vm.startPrank(seller);
        token.setApprovalForAll(address(marketplace), true);
        bytes32 orderId = marketplace.createOrder(
            address(token),
            10001,
            5,
            10 ether,
            address(0),
            block.timestamp + 1 days,
            false
        );
        vm.stopPrank();

        (
            address orderSeller,
            ,
            uint256 tokenId,
            uint256 amount,
            uint256 price,
            ,
            uint256 expiry,

        ) = marketplace.orders(orderId);

        assertEq(orderSeller, seller);
        assertEq(tokenId, 10001);
        assertEq(amount, 5);
        assertEq(price, 10 ether);
        assertGt(expiry, block.timestamp);
    }

    function testExecuteOrderNonEscrowed() public {
        vm.startPrank(seller);
        token.setApprovalForAll(address(marketplace), true);
        bytes32 orderId = marketplace.createOrder(
            address(token),
            10001,
            1,
            10 ether,
            address(0),
            block.timestamp + 1 days,
            false
        );
        vm.stopPrank();

        vm.prank(buyer);
        marketplace.executeOrder{value: 10 ether}(orderId);

        assertEq(token.balanceOf(buyer, 10001), 1);
        assertEq(token.balanceOf(seller, 10001), 9);
        assertEq(buyer.balance, 0);
        assertEq(seller.balance, 20 ether);
    }

    function testCancelOrderNonEscrowed() public {
        vm.startPrank(seller);

        token.setApprovalForAll(address(marketplace), true);
        bytes32 orderId = marketplace.createOrder(
            address(token),
            10001,
            1,
            10 ether,
            address(0),
            block.timestamp + 1 days,
            false
        );

        marketplace.cancelOrder(orderId);

        vm.stopPrank();

        (address orderSeller, , , , , , , ) = marketplace.orders(orderId);

        assertEq(orderSeller, address(0)); // Order should be deleted
    }

    function testCreateOrderEscrowed() public {
        vm.startPrank(seller);
        token.setApprovalForAll(address(marketplace), true);
        bytes32 orderId = marketplace.createOrder(
            address(token),
            10001,
            5,
            10 ether,
            address(0),
            block.timestamp + 1 days,
            true
        );
        vm.stopPrank();

        (
            address orderSeller,
            ,
            uint256 tokenId,
            uint256 amount,
            uint256 price,
            ,
            uint256 expiry,

        ) = marketplace.orders(orderId);

        assertEq(orderSeller, seller);
        assertEq(tokenId, 10001);
        assertEq(amount, 5);
        assertEq(price, 10 ether);
        assertGt(expiry, block.timestamp);

        assertEq(token.balanceOf(address(marketplace), 10001), 5);
        assertEq(token.balanceOf(seller, 10001), 5);
    }

    function testExecuteOrderEscrowed() public {
        vm.startPrank(seller);
        token.setApprovalForAll(address(marketplace), true);
        bytes32 orderId = marketplace.createOrder(
            address(token),
            10001,
            1,
            10 ether,
            address(0),
            block.timestamp + 1 days,
            true
        );
        vm.stopPrank();

        vm.prank(buyer);
        marketplace.executeOrder{value: 10 ether}(orderId);

        assertEq(token.balanceOf(address(marketplace), 10001), 0);
        assertEq(token.balanceOf(seller, 10001), 9);
        assertEq(token.balanceOf(buyer, 10001), 1);
        assertEq(buyer.balance, 0);
        assertEq(seller.balance, 20 ether);
    }

    function testCancelOrderEscrowed() public {
        vm.startPrank(seller);

        token.setApprovalForAll(address(marketplace), true);
        bytes32 orderId = marketplace.createOrder(
            address(token),
            10001,
            1,
            10 ether,
            address(0),
            block.timestamp + 1 days,
            true
        );

        assertEq(token.balanceOf(address(marketplace), 10001), 1);
        assertEq(token.balanceOf(seller, 10001), 9);

        marketplace.cancelOrder(orderId);

        assertEq(token.balanceOf(address(marketplace), 10001), 0);
        assertEq(token.balanceOf(seller, 10001), 10);

        vm.stopPrank();

        (address orderSeller, , , , , , , ) = marketplace.orders(orderId);

        assertEq(orderSeller, address(0)); // Order should be deleted
    }
}
