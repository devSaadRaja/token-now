// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./RealEstateToken.sol";

contract RealEstateFactory is Ownable {
    // =================== STRUCTURE =================== //

    uint256 public plazaCount;
    mapping(string => uint256) public floorCount;
    mapping(string => uint256) public roomCount;

    mapping(address => bool) minters;

    // =================== MODIFIERS =================== //

    modifier onlyMinter(address account) {
        require(minters[account], "Caller is not a minter");
        _;
    }

    // =================== EVENTS =================== //

    event RealEstateCreated(
        address indexed contractAddress,
        string indexed tokenID,
        address indexed owner,
        string uri
    );

    // =================== CONSTRUCTOR =================== //

    constructor(address owner) Ownable(owner) {}

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

    function createRealEstate(
        string memory tokenType,
        string memory plazaId,
        string memory floorId,
        string memory uri
    ) external {
        string memory id = _generateID(tokenType, plazaId, floorId);
        RealEstateToken newContract = new RealEstateToken(msg.sender, "", uri);

        emit RealEstateCreated(address(newContract), id, msg.sender, uri);
    }

    function _generateID(
        string memory tokenType,
        string memory plazaId,
        string memory floorId
    ) internal returns (string memory) {
        if (keccak256(abi.encodePacked(tokenType)) == keccak256("plaza")) {
            plazaCount++;
            return string(abi.encodePacked("P", _formatID(plazaCount)));
        } else if (
            keccak256(abi.encodePacked(tokenType)) == keccak256("floor")
        ) {
            require(bytes(plazaId).length > 0, "Plaza ID required");
            floorCount[plazaId]++;
            return
                string(
                    abi.encodePacked(
                        plazaId,
                        "F",
                        _formatID(floorCount[plazaId])
                    )
                );
        } else if (
            keccak256(abi.encodePacked(tokenType)) == keccak256("room")
        ) {
            require(
                bytes(plazaId).length > 0 && bytes(floorId).length > 0,
                "Plaza and Floor ID required"
            );
            roomCount[string(abi.encodePacked(plazaId, floorId))]++;
            return
                string(
                    abi.encodePacked(
                        plazaId,
                        floorId,
                        "R",
                        _formatID(
                            roomCount[
                                string(abi.encodePacked(plazaId, floorId))
                            ]
                        )
                    )
                );
        } else {
            revert("Invalid token type");
        }
    }

    function _formatID(uint256 number) internal pure returns (string memory) {
        if (number < 10) {
            return string(abi.encodePacked("00", _uintToString(number)));
        } else if (number < 100) {
            return string(abi.encodePacked("0", _uintToString(number)));
        } else {
            return _uintToString(number);
        }
    }

    function _uintToString(
        uint256 value
    ) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
