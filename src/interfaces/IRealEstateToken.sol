// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IRealEstateToken is IERC1155 {
    // View Functions
    function isMinter(address account) external view returns (bool);
    function getSupply(uint256 tokenId) external view returns (uint256);
    function getOwners(uint256 tokenId) external view returns (address[] memory);
    function contractURI() external view returns (string memory);
    function uri(uint256 tokenId) external view returns (string memory);
    function ifChildIdExists(
        string memory assetType,
        uint256 parentId
    ) external view returns (bool);

    // State-Changing Functions
    function addMinter(address minter) external;
    function removeMinter(address minter) external;
    function setContractURI(string memory _uri) external;
    function setBaseURI(string memory newuri) external;
    function setURI(uint256 tokenId, string memory newuri) external;
    
    function mint(
        address account,
        string memory assetType,
        uint256 parentId,
        uint256 amount,
        string memory _uri,
        bytes memory data
    ) external;

    // Events
    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);
    event ContractURIUpdated(string contractURI);
    event AssetCreated(
        string assetType,
        uint256 indexed tokenId,
        address indexed owner,
        string uri
    );
} 