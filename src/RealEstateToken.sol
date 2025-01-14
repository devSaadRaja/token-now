// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

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

    // =================== CONSTRUCTOR =================== //

    constructor() ERC1155("") Ownable(msg.sender) {
        minters[msg.sender] = true;
    }

    // =================== FUNCTIONS =================== //

    function isMinter(address account) external view returns (bool) {
        return minters[account];
    }

    function addMinter(address minter) external onlyOwner {
        minters[minter] = true;
    }

    function removeMinter(address minter) external onlyOwner {
        minters[minter] = false;
    }

    function setContractURI(string memory _uri) external onlyOwner {
        contractURI = _uri;
    }

    function setBaseURI(string memory newuri) external onlyOwner {
        _setBaseURI(newuri);
    }

    function setURI(uint256 tokenId, string memory newuri) external onlyOwner {
        _setURI(tokenId, newuri);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external onlyMinter(msg.sender) {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external onlyMinter(msg.sender) {
        _mintBatch(to, ids, amounts, data);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
