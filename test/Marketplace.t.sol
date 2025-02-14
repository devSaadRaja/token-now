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
        vm.stopPrank();
    }

    function testCreateOrder() public {
        vm.startPrank(seller);
        token.setApprovalForAll(address(marketplace), true);
        bytes32 orderId = marketplace.createOrder(
            address(token),
            10001,
            5,
            10 ether,
            address(0),
            block.timestamp + 1 days
        );
        vm.stopPrank();

        (
            address orderSeller,
            ,
            uint256 tokenId,
            uint256 amount,
            uint256 price,
            ,
            uint256 expiry
        ) = marketplace.orders(orderId);

        assertEq(orderSeller, seller);
        assertEq(tokenId, 10001);
        assertEq(amount, 5);
        assertEq(price, 10 ether);
        assertGt(expiry, block.timestamp);
    }

    function testExecuteOrder() public {
        vm.startPrank(seller);
        token.setApprovalForAll(address(marketplace), true);
        bytes32 orderId = marketplace.createOrder(
            address(token),
            10001,
            1,
            10 ether,
            address(0),
            block.timestamp + 1 days
        );
        vm.stopPrank();

        vm.prank(buyer);
        marketplace.executeOrder{value: 10 ether}(orderId);

        assertEq(token.balanceOf(buyer, 10001), 1);
        assertEq(token.balanceOf(seller, 10001), 9);
        assertEq(buyer.balance, 0);
        assertEq(seller.balance, 20 ether);
    }

    function testCancelOrder() public {
        vm.startPrank(seller);

        token.setApprovalForAll(address(marketplace), true);
        bytes32 orderId = marketplace.createOrder(
            address(token),
            10001,
            1,
            10 ether,
            address(0),
            block.timestamp + 1 days
        );

        marketplace.cancelOrder(orderId);

        vm.stopPrank();

        (address orderSeller, , , , , , ) = marketplace.orders(orderId);

        assertEq(orderSeller, address(0)); // Order should be deleted
    }
}
