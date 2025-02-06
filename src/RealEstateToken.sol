// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Test.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

contract RealEstateToken is ERC1155URIStorage, Ownable {
    // =================== STRUCTURE =================== //

    string public contractURI;

    mapping(address => bool) minters;

    // =================== MODIFIERS =================== //

    modifier onlyMinter(address account) {
        require(minters[account], "Caller is not a minter");
        _;
    }

    // =================== EVENTS =================== //

    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);
    event ContractURIUpdated(string contractURI);
    event AssetCreated(
        uint256 indexed tokenID,
        address indexed owner,
        string uri
    );

    // =================== CONSTRUCTOR =================== //

    constructor(
        address owner,
        string memory tokenUri
    ) ERC1155(tokenUri) Ownable(owner) {
        minters[owner] = true;
    }

    // =================== FUNCTIONS =================== //

    function isMinter(address account) external view returns (bool) {
        return minters[account];
    }

    function addMinter(address minter) external onlyOwner {
        minters[minter] = true;
        emit MinterAdded(minter);
    }

    function removeMinter(address minter) external onlyOwner {
        minters[minter] = false;
        emit MinterRemoved(minter);
    }

    function setContractURI(string memory _uri) external onlyOwner {
        contractURI = _uri;
        emit ContractURIUpdated(contractURI);
    }

    // function setBaseURI(string memory newuri) external onlyOwner {
    //     _setBaseURI(newuri);
    // }

    function setURI(
        uint256 tokenId,
        string memory newuri
    ) external onlyMinter(msg.sender) {
        require(balanceOf(msg.sender, tokenId) > 0, "Not the token owner");
        _setURI(tokenId, newuri);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        string memory _uri,
        bytes memory data
    ) external onlyMinter(msg.sender) {
        _mint(account, id, amount, data);

        if (bytes(_uri).length > 0) _setURI(id, _uri);
        else _uri = uri(id);

        emit AssetCreated(id, account, _uri);
    }

    // function mintBatch(
    //     address to,
    //     uint256[] memory ids,
    //     uint256[] memory amounts,
    //     string[] memory uri,
    //     bytes memory data
    // ) external onlyMinter(msg.sender) {
    //     _mintBatch(to, ids, amounts, data);

    //     for (uint i = 0; i < ids.length; i++) {
    //         emit AssetCreated(ids[i], to, uri[i]);
    //     }
    // }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
