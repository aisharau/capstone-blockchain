// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//importing openzeppelin for security
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/access/Ownable.sol";

contract HalalVer is Ownable {
    struct Batch {
        uint256 batchId;
        string rfidTag;
        string ipfsHash; //links to halal certificates
        string productCategory;

        //IoT layers
        int256 temp;
        uint256 humdt;
        uint256 gasSen;
        string location; //gps
        bool isTampered; //light/camera sensors
        uint256 timestamp;

        bool isValid;
    }

    mapping(uint256 => Batch) public batches;

    event BatchLogged(uint256 indexed batchId, bool isValid);

    function logBatchData(
        uint256 _id, 
        string memory _rfid, 
        string memory _cid,
        string memory _category,
        int256 _temp,
        uint256 _humdt,
        uint256 _gasSen,
        string memory _location,
        bool _tamper
    ) public onlyOwner {
        //Validation for security
        require(_id > 0, "Invalid batch ID");
        require(bytes(_rfid).length > 0, "RFID tag cannot be empty");
        require(bytes(_cid).length > 0, "IPFS Hash cannot be empty");
        require(bytes(_category).length > 0, "Product category cannot be empty");
        require(_temp >= -50 && _temp <= 50, "Temperature out of range");
        require(_humdt <= 100, "Humidity cannot exceed 100%");
        require(bytes(_location).length > 0, "Location cannot be empty");

        bool valid = !_tamper; //invalid if tampered

        batches[_id] = Batch(
            _id, 
            _rfid, 
            _cid, 
            _category, 
            _temp, 
            _humdt, 
            _gasSen, 
            _location, 
            _tamper, 
            block.timestamp, 
            valid);

        //emit event for transparency
        emit BatchLogged(_id, valid);
    }

    //QR code trigger
    function verifyBatch(uint256 _id) public view returns (
        uint256 id,
        string memory rfid,
        string memory cid,
        string memory category,
        int256 temp,
        uint256 humdt,
        uint256 gasSen,
        string memory location,
        bool tamper,
        uint256 time,
        bool valid
    ) {
        Batch memory b = batches[_id];
        require(b.batchId != 0, "Batch not found"); //to ensure batch exists
        return (b.batchId, b.rfidTag, b.ipfsHash, b.productCategory, b.temp, b.humdt, b.gasSen, b.location, b.isTampered, b.timestamp, b.isValid);
    }
}