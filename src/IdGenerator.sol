// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract IdGenerator {
    uint256 private plazaCounter = 10000;
    mapping(uint256 => uint256) private floorCounters;
    mapping(uint256 => mapping(uint256 => uint256)) private roomCounters;

    mapping(uint256 => bool) private existingPlazas;
    mapping(uint256 => bool) private existingFloors;

    function _generateID(
        string memory assetType,
        uint256 parentID
    ) internal returns (uint256) {
        bytes1 assetChar = bytes(assetType)[0];

        if (assetChar == "p" || assetChar == "P") {
            return _generatePlazaID();
        } else if (assetChar == "f" || assetChar == "F") {
            require(
                existingPlazas[parentID],
                "Plaza must exist before creating a floor"
            );
            return _generateFloorID(parentID);
        } else if (assetChar == "r" || assetChar == "R") {
            require(
                existingFloors[parentID],
                "Plaza and Floor must exist before creating a room"
            );
            return _generateRoomID(parentID);
        } else {
            revert("Invalid asset type");
        }
    }

    function _generatePlazaID() private returns (uint256) {
        plazaCounter++;
        existingPlazas[plazaCounter] = true;
        return plazaCounter;
    }

    function _generateFloorID(uint256 plazaID) private returns (uint256) {
        floorCounters[plazaID]++;
        uint256 floorID = plazaID * 1000 + floorCounters[plazaID];
        existingFloors[floorID] = true;
        return floorID;
    }

    function _generateRoomID(uint256 floorID) private returns (uint256) {
        uint256 plazaID = floorID / 1000;
        roomCounters[plazaID][floorID]++;
        return floorID * 1000 + roomCounters[plazaID][floorID];
    }
}
