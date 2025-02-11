// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Test.sol";
import {RealEstateToken} from "../src/RealEstateToken.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract RealEstateTokenTest is Test {
    address public owner = vm.addr(1);
    address public user1 = vm.addr(2);
    address public user2 = vm.addr(3);

    RealEstateToken public token;

    bytes data = "";

    function setUp() public {
        vm.startPrank(owner); // OWNER
        token = new RealEstateToken(
            owner,
            "",
            "https://gateway.pinata.cloud/ipfs/"
        );
        vm.stopPrank(); // OWNER
    }

    function testMint() public {
        vm.startPrank(owner);

        console.log(token.uri(10001), "<<< BEFORE");
        token.mint(
            owner,
            10001,
            1,
            "QmdAcTQR8R5f23Rx4WeKg9WiK935QnsBYxPJawnJ3W7Hyd",
            data
        );
        console.log(token.uri(10001), "<<< AFTER");
        token.mint(
            owner,
            10001,
            1,
            "",
            data
        );
        console.log(token.uri(10001), "<<<");

        // token.mint(user1, 10001, 1, "abc", data);
        // assertEq(token.balanceOf(user1, 10001), 1);
        // assertEq(token.getOwners(10001).length, 1);
        // assertEq(token.uri(10001), "https://gateway.pinata.cloud/ipfs/abc");

        // token.mint(user1, 10001001, 1, "abc", data);
        // assertEq(token.balanceOf(user1, 10001), 0);
        // assertEq(token.balanceOf(user1, 10001001), 1);
        // assertEq(token.getOwners(10001).length, 0);
        // assertEq(token.getOwners(10001001).length, 1);
        // assertEq(token.uri(10001), "https://gateway.pinata.cloud/ipfs/abc");
        // assertEq(token.uri(10001001), "https://gateway.pinata.cloud/ipfs/abc");

        // token.mint(user1, 10001001001, 1, "abc", data);
        // assertEq(token.balanceOf(user1, 10001), 0);
        // assertEq(token.balanceOf(user1, 10001001), 0);
        // assertEq(token.balanceOf(user1, 10001001001), 1);
        // assertEq(token.getOwners(10001).length, 0);
        // assertEq(token.getOwners(10001001).length, 0);
        // assertEq(token.getOwners(10001001001).length, 1);
        // assertEq(token.uri(10001), "https://gateway.pinata.cloud/ipfs/abc");
        // assertEq(token.uri(10001001), "https://gateway.pinata.cloud/ipfs/abc");
        // assertEq(token.uri(10001001001), "https://gateway.pinata.cloud/ipfs/abc");

        vm.stopPrank();
    }

    // function testFailMintByNonMinter() public {
    //     vm.startPrank(user1);
    //     token.mint(user1, 1, 10, data);
    //     vm.stopPrank();
    // }

    // function testSetBaseURI() public {
    //     vm.startPrank(owner);

    //     // token.mint(owner, 1, 10, "https://realestate.example/", data);
    //     token.mint(
    //         owner,
    //         RealEstateToken.AssetType.Plaza,
    //         0,
    //         1,
    //         10,
    //         "https://realestate.example/",
    //         data
    //     );
    //     assertEq(token.uri(1), "https://realestate.example/");

    //     // string memory newURI = "https://realestate.example/";
    //     // token.setBaseURI(newURI);

    //     token.setURI(1, "https://realestate.example/1.json");
    //     assertEq(token.uri(1), "https://realestate.example/1.json");

    //     vm.stopPrank();
    // }

    // function testFailSetURIByNonURISetter() public {
    //     vm.startPrank(user1);
    //     token.setURI(1, "https://malicious.example/1.json");
    //     vm.stopPrank();
    // }

    // function testGrantMinterRole() public {
    //     vm.startPrank(owner);
    //     token.addMinter(user1);
    //     vm.stopPrank();

    //     vm.startPrank(user1);
    //     // token.mint(user2, 2, 5, "", data);
    //     token.mint(user2, RealEstateToken.AssetType.Plaza, 0, 2, 5, "", data);
    //     vm.stopPrank();

    //     assertEq(token.balanceOf(user2, 2), 5);
    // }

    // function testFailMintBatchByNonMinter() public {
    //     uint256[] memory ids = new uint256[](2);
    //     uint256[] memory amounts = new uint256[](2);
    //     ids[0] = 1;
    //     ids[1] = 2;
    //     amounts[0] = 5;
    //     amounts[1] = 10;

    //     vm.startPrank(user1);
    //     // vm.expectRevert();
    //     token.mintBatch(user2, ids, amounts, data);
    //     vm.stopPrank();
    // }

    // function testSupportsInterface() public {
    //     bool supports = token.supportsInterface(type(IERC1155).interfaceId);
    //     assertTrue(supports);
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     token.setNumber(x);
    //     console.log(token.number());
    //     assertEq(token.number(), x);
    // }
}
