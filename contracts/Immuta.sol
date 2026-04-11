// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Immuta {
    address public owner;
    IERC20 public usdc;
    uint256 public fee = 1_000_000;

    struct Record {
        bytes32 hash;
        address submitter;
        uint256 timestamp;
        string label;
        string note;
    }

    mapping(bytes32 => Record) public records;

    event HashStored(
        bytes32 indexed hash,
        address indexed submitter,
        uint256 timestamp,
        string label,
        string note
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _usdc) {
        owner = msg.sender;
        usdc = IERC20(_usdc);
    }

    function storeHash(
        bytes32 _hash,
        string calldata _label,
        string calldata _note
    ) external {
        require(records[_hash].timestamp == 0, "Already sealed");
        require(bytes(_label).length <= 100, "Label too long");
        require(bytes(_note).length <= 500, "Note too long");
        require(
            usdc.transferFrom(msg.sender, address(this), fee),
            "Fee payment failed"
        );
        records[_hash] = Record(_hash, msg.sender, block.timestamp, _label, _note);
        emit HashStored(_hash, msg.sender, block.timestamp, _label, _note);
    }

    function getRecord(bytes32 _hash) external view returns (Record memory) {
        return records[_hash];
    }

    function setFee(uint256 _newFee) external onlyOwner {
        require(_newFee <= 10_000_000, "Capped at $10");
        fee = _newFee;
    }

    function withdraw() external onlyOwner {
        usdc.transfer(owner, usdc.balanceOf(address(this)));
    }
}
