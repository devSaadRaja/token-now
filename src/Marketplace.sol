// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import "./interfaces/IRealEstateToken.sol";

contract Marketplace is ReentrancyGuard, ERC1155Holder {
    // =================== STRUCTURE =================== //

    struct Order {
        address seller;
        string assetType;
        address token;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        address paymentToken;
        uint256 expiry;
        bool escrowed;
    }

    mapping(bytes32 => Order) public orders;
    mapping(bytes32 => bool) public executedOrders;

    // seller -> tokenAddress -> tokenId = amount
    mapping(address => mapping(address => mapping(uint256 => uint256))) escrowedListedAmounts;
    mapping(address => mapping(address => mapping(uint256 => uint256))) nonEscrowedListedAmounts;

    // =================== EVENTS =================== //

    event OrderCreated(
        address indexed seller,
        string assetType,
        bytes32 orderId,
        uint256 tokenId,
        uint256 amount,
        uint256 price,
        bool escrowed
    );
    event OrderExecuted(
        address indexed buyer,
        string assetType,
        bytes32 orderId,
        uint256 tokenId,
        uint256 amount,
        uint256 price
    );
    event OrderCancelled(bytes32 orderId);

    // =================== FUNCTIONS =================== //

    function getEscrowedListedAmount(
        address seller,
        address token,
        uint256 tokenId
    ) external view returns (uint256) {
        return escrowedListedAmounts[seller][token][tokenId];
    }

    function getNonEscrowedListedAmount(
        address seller,
        address token,
        uint256 tokenId
    ) external view returns (uint256) {
        return nonEscrowedListedAmounts[seller][token][tokenId];
    }

    function createOrder(
        string memory assetType,
        address token,
        uint256 tokenId,
        uint256 amount,
        uint256 price,
        address paymentToken,
        uint256 expiry,
        bool escrowed
    ) external returns (bytes32 orderId) {
        require(
            !IRealEstateToken(token).ifChildIdExists("p", tokenId) &&
                !IRealEstateToken(token).ifChildIdExists("f", tokenId),
            "Cannot sell token with existing children"
        );
        require(expiry > block.timestamp, "Expiry must be in the future");
        require(amount > 0, "Amount must be greater than zero");

        orderId = keccak256(
            abi.encode(
                msg.sender,
                assetType,
                token,
                tokenId,
                amount,
                price,
                paymentToken,
                expiry
            )
        );
        require(orders[orderId].seller == address(0), "Order already exists");

        IERC1155 asset = IERC1155(token);
        uint256 sellerBalance = asset.balanceOf(msg.sender, tokenId);
        uint256 reserved = nonEscrowedListedAmounts[msg.sender][token][tokenId];
        require(
            sellerBalance >= reserved + amount,
            "Not enough tokens available"
        );

        if (escrowed) {
            asset.safeTransferFrom(
                msg.sender,
                address(this),
                tokenId,
                amount,
                ""
            );

            escrowedListedAmounts[msg.sender][token][tokenId] += amount;
        } else {
            nonEscrowedListedAmounts[msg.sender][token][tokenId] += amount;
        }

        orders[orderId] = Order({
            seller: msg.sender,
            assetType: assetType,
            token: token,
            tokenId: tokenId,
            amount: amount,
            price: price,
            paymentToken: paymentToken,
            expiry: expiry,
            escrowed: escrowed
        });

        emit OrderCreated(
            msg.sender,
            assetType,
            orderId,
            tokenId,
            amount,
            price,
            escrowed
        );
    }

    function executeOrder(bytes32 orderId) external payable nonReentrant {
        Order memory order = orders[orderId];
        require(order.seller != address(0), "Order does not exist");
        require(!executedOrders[orderId], "Order already executed");
        require(order.expiry > block.timestamp, "Order expired");

        executedOrders[orderId] = true;

        if (order.paymentToken == address(0)) {
            require(msg.value == order.price, "Incorrect ETH sent");
            (bool success, ) = payable(order.seller).call{value: order.price}(
                ""
            );
            require(success, "ETH transfer failed");
        } else {
            IERC20(order.paymentToken).transferFrom(
                msg.sender,
                order.seller,
                order.price
            );
        }

        if (order.escrowed) {
            IERC1155(order.token).safeTransferFrom(
                address(this),
                msg.sender,
                order.tokenId,
                order.amount,
                ""
            );

            escrowedListedAmounts[order.seller][order.token][
                order.tokenId
            ] -= order.amount;
        } else {
            IERC1155(order.token).safeTransferFrom(
                order.seller,
                msg.sender,
                order.tokenId,
                order.amount,
                ""
            );

            nonEscrowedListedAmounts[order.seller][order.token][
                order.tokenId
            ] -= order.amount;
        }

        emit OrderExecuted(
            msg.sender,
            order.assetType,
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

        if (order.escrowed) {
            IERC1155(order.token).safeTransferFrom(
                address(this),
                msg.sender,
                order.tokenId,
                order.amount,
                ""
            );

            escrowedListedAmounts[order.seller][order.token][
                order.tokenId
            ] -= order.amount;
        } else {
            nonEscrowedListedAmounts[order.seller][order.token][
                order.tokenId
            ] -= order.amount;
        }

        delete orders[orderId];
        emit OrderCancelled(orderId);
    }

    // function _checkDuplicateOrder(
    //     address seller,
    //     address token,
    //     uint256 tokenId,
    //     uint256 amount,
    //     uint256 price,
    //     address paymentToken,
    //     uint256 expiry
    // ) internal view returns (bool) {
    //     bytes32 orderId = keccak256(
    //         abi.encode(
    //             seller,
    //             token,
    //             tokenId,
    //             amount,
    //             price,
    //             paymentToken,
    //             expiry
    //         )
    //     );
    //     return orders[orderId].seller != address(0);
    // }

    // function _checkDuplicateOrder() internal view returns (bool) {}
}
