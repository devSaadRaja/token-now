// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Test.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

contract RealEstateToken is ERC1155URIStorage, Ownable {
    // =================== STRUCTURE =================== //

    string public contractURI;

    mapping(address => bool) minters;
    mapping(uint256 => uint256) supply; // Track supply per token ID
    mapping(uint256 => address[]) owners; // Track owners per token ID

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

    function getSupply(uint256 tokenId) external view returns (uint256) {
        return supply[tokenId];
    }

    function getOwners(
        uint256 tokenId
    ) external view returns (address[] memory) {
        return owners[tokenId];
    }

    function exists(uint256 tokenId) public view returns (bool) {
        // return supply[tokenId] > 0;
        return bytes(uri(tokenId)).length > 0;
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
    ) external {
        // onlyMinter(msg.sender)

        // _validateId(id);
        _mint(account, id, amount, data);
        supply[id] += amount;
        // owners[id].push(account);
        // _updatePreviousOwnerships(msg.sender, id);

        if (bytes(_uri).length > 0) _setURI(id, _uri);
        else _uri = uri(id);

        emit AssetCreated(id, account, _uri);
    }

    function _updatePreviousOwnerships(address minter, uint256 id) internal {
        if (id >= 1_000_000_000) {
            // Room ID (e.g., 10001001001)
            uint256 floorId = id / 1000; // Extract floor ID
            _removeSupply(minter, floorId);
        } else if (id >= 1_000_000) {
            // Floor ID (e.g., 10001001)
            uint256 plazaId = (id / 1000); // Extract plaza ID
            _removeSupply(minter, plazaId);
        }
    }

    function _removeSupply(address minter, uint256 id) internal {
        require(balanceOf(minter, id) > 0);

        supply[id] = 0;
        for (uint i = 0; i < owners[id].length; i++) {
            address owner = owners[id][i];
            _burn(owner, id, balanceOf(owner, id));
        }
        delete owners[id];
    }

    function _validateId(uint256 id) internal view {
        require(!exists(id), "Token already exists");
        if (id >= 1_000_000_000) {
            // Room ID (e.g., 10001001001)
            uint256 plazaId = id / 1_000_000; // Extract plaza ID
            uint256 floorId = id / 1000; // Extract floor ID
            require(exists(floorId), "Floor must exist");
            require(exists(plazaId), "Plaza must exist");
        } else if (id >= 1_000_000) {
            // Floor ID (e.g., 10001001)
            uint256 plazaId = (id / 1000); // Extract plaza ID
            require(exists(plazaId), "Plaza must exist");
        }
        // Plaza (e.g., 10001) does not need a check because it should not exist before.
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
