// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Test.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

import {IdGenerator} from "./IdGenerator.sol";

contract RealEstateToken is ERC1155URIStorage, Ownable, IdGenerator {
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
        string assetType,
        uint256 indexed tokenID,
        uint256 amount,
        address indexed owner,
        string uri
    );

    // =================== CONSTRUCTOR =================== //

    constructor(
        address _owner,
        string memory _contractUri,
        string memory _baseUri
    ) ERC1155("") Ownable(_owner) {
        contractURI = _contractUri;
        _setBaseURI(_baseUri);
        minters[_owner] = true;
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

    // function exists(uint256 tokenId) public view returns (bool) {
    //     // return supply[tokenId] > 0;
    //     return bytes(uri(tokenId)).length > 0;
    // }

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

    function setBaseURI(string memory newuri) external onlyOwner {
        _setBaseURI(newuri);
    }

    function setURI(
        uint256 tokenId,
        string memory newuri
    ) external onlyMinter(msg.sender) {
        require(balanceOf(msg.sender, tokenId) > 0, "Not the token owner");
        _setURI(tokenId, newuri);
    }

    function mint(
        address account,
        string memory assetType,
        uint256 parentId,
        uint256 amount,
        string memory _uri,
        bytes memory data
    ) external {
        // onlyMinter(msg.sender)

        if (parentId > 0) {
            require(balanceOf(msg.sender, parentId) > 0, "Not the token owner");
        }

        uint256 id = _generateID(assetType, parentId);

        // _validateId(id);

        _mint(account, id, amount, data);
        supply[id] += amount;

        // owners[id].push(account);
        // _updatePreviousOwnerships(msg.sender, id);

        if (bytes(_uri).length > 0) _setURI(id, _uri);

        emit AssetCreated(assetType, id, amount, account, uri(id));
    }

    // function _updatePreviousOwnerships(address minter, uint256 id) internal {
    //     if (id >= 1_000_000_000) {
    //         // Room ID (e.g., 10001001001)
    //         uint256 floorId = id / 1000; // Extract floor ID
    //         _removeSupply(minter, floorId);
    //     } else if (id >= 1_000_000) {
    //         // Floor ID (e.g., 10001001)
    //         uint256 plazaId = (id / 1000); // Extract plaza ID
    //         _removeSupply(minter, plazaId);
    //     }
    // }

    // function _removeSupply(address minter, uint256 id) internal {
    //     require(balanceOf(minter, id) > 0);

    //     supply[id] = 0;
    //     for (uint i = 0; i < owners[id].length; i++) {
    //         address owner = owners[id][i];
    //         _burn(owner, id, balanceOf(owner, id));
    //     }
    //     delete owners[id];
    // }

    // function _validateId(uint256 id) internal view {
    //     require(!exists(id), "Token already exists");
    //     if (id >= 1_000_000_000) {
    //         // Room ID (e.g., 10001001001)
    //         uint256 plazaId = id / 1_000_000; // Extract plaza ID
    //         uint256 floorId = id / 1000; // Extract floor ID
    //         require(exists(floorId), "Floor must exist");
    //         require(exists(plazaId), "Plaza must exist");
    //     } else if (id >= 1_000_000) {
    //         // Floor ID (e.g., 10001001)
    //         uint256 plazaId = (id / 1000); // Extract plaza ID
    //         require(exists(plazaId), "Plaza must exist");
    //     }
    //     // Plaza (e.g., 10001) does not need a check because it should not exist before.
    // }

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

    // function mintBatch(
    //     address account,
    //     string[] memory assetTypes,
    //     uint256[] memory parentIds,
    //     uint256[] memory amounts,
    //     string[] memory uris,
    //     bytes[] memory datas
    // ) external {
    //     require(
    //         assetTypes.length == parentIds.length &&
    //             parentIds.length == amounts.length &&
    //             amounts.length == uris.length &&
    //             uris.length == datas.length,
    //         "Arrays length mismatch"
    //     );

    //     for (uint256 i = 0; i < assetTypes.length; i++) {
    //         if (parentIds[i] > 0) {
    //             require(
    //                 balanceOf(msg.sender, parentIds[i]) > 0,
    //                 "Not the token owner"
    //             );
    //         }

    //         uint256 id = _generateID(assetTypes[i], parentIds[i]);

    //         _mint(account, id, amounts[i], datas[i]);
    //         supply[id] += amounts[i];

    //         if (bytes(uris[i]).length > 0) _setURI(id, uris[i]);

    //         emit AssetCreated(assetTypes[i], id, amounts[i], account, uri(id));
    //     }
    // }
}
