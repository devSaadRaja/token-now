// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    // =================== STRUCTURE =================== //

    struct Order {
        address seller;
        address token;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        address paymentToken;
        uint256 expiry;
    }

    mapping(bytes32 => Order) public orders;
    mapping(bytes32 => bool) public executedOrders;

    // =================== EVENTS =================== //

    event OrderCreated(
        address indexed seller,
        bytes32 orderId,
        uint256 tokenId,
        uint256 amount,
        uint256 price
    );
    event OrderExecuted(
        address indexed buyer,
        bytes32 orderId,
        uint256 tokenId,
        uint256 amount,
        uint256 price
    );
    event OrderCancelled(bytes32 orderId);

    // =================== FUNCTIONS =================== //

    function createOrder(
        address token,
        uint256 tokenId,
        uint256 amount,
        uint256 price,
        address paymentToken,
        uint256 expiry
    ) external returns (bytes32 orderId) {
        require(expiry > block.timestamp, "Expiry must be in the future");
        require(amount > 0, "Amount must be greater than zero");

        orderId = keccak256(
            abi.encode(
                msg.sender,
                token,
                tokenId,
                amount,
                price,
                paymentToken,
                expiry
            )
        );
        require(orders[orderId].seller == address(0), "Order already exists");

        orders[orderId] = Order({
            seller: msg.sender,
            token: token,
            tokenId: tokenId,
            amount: amount,
            price: price,
            paymentToken: paymentToken,
            expiry: expiry
        });

        emit OrderCreated(msg.sender, orderId, tokenId, amount, price);
    }

    function executeOrder(bytes32 orderId) external payable nonReentrant {
        Order memory order = orders[orderId];
        require(order.seller != address(0), "Order does not exist");
        require(!executedOrders[orderId], "Order already executed");
        require(order.expiry > block.timestamp, "Order expired");

        executedOrders[orderId] = true;

        if (order.paymentToken == address(0)) {
            require(msg.value == order.price, "Incorrect ETH sent");
            payable(order.seller).transfer(order.price);
        } else {
            IERC20(order.paymentToken).transferFrom(
                msg.sender,
                order.seller,
                order.price
            );
        }

        IERC1155(order.token).safeTransferFrom(
            order.seller,
            msg.sender,
            order.tokenId,
            order.amount,
            ""
        );
        emit OrderExecuted(
            msg.sender,
            orderId,
            order.tokenId,
            order.amount,
            order.price
        );
    }

    function cancelOrder(bytes32 orderId) external {
        Order memory order = orders[orderId];
        require(order.seller == msg.sender, "Only seller can cancel");
        require(!executedOrders[orderId], "Order already executed");
        delete orders[orderId];
        emit OrderCancelled(orderId);
    }
}
