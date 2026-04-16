// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24; // Final audited version

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract Immuta is ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    address public owner;
    address public pendingOwner;
    address public feeRecipient;

    mapping(address => uint256) public tokenFees;
    mapping(address => bool) public acceptedTokens;

    // Key: keccak256(abi.encode(submitter, hash)) — binds authorship to sender
    mapping(bytes32 => Record) public records;

    struct Record {
        bytes32 hash;
        address submitter;
        uint256 timestamp;
        string label;
        string note;
        address token;
    }

    // Custom errors — cheaper than revert strings
    error NotOwner();
    error NotPendingOwner();
    error TokenNotAccepted();
    error AlreadySealed();
    error LabelRequired();
    error LabelTooLong();
    error NoteTooLong();
    error InvalidAddress();
    error InvalidFee();
    error TokenAlreadyAccepted();

    event HashStored(
        bytes32 indexed hash,
        address indexed submitter,
        address indexed token,
        uint256 timestamp,
        string label,
        string note
    );
    event TokenAdded(address indexed token, uint256 fee);
    event TokenRemoved(address indexed token);
    event FeeRecipientChanged(address indexed oldRecipient, address indexed newRecipient);
    event OwnershipTransferStarted(address indexed currentOwner, address indexed pendingOwner);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(
        address _owner,
        address _feeRecipient,
        address _usdc,
        address _usdt,
        address _dai
    ) {
        if (_owner == address(0)) revert InvalidAddress();
        if (_feeRecipient == address(0)) revert InvalidAddress();

        owner = _owner;
        feeRecipient = _feeRecipient;

        _addToken(_usdc, 1_000_000);                    // eUSDC — 6 decimals
        _addToken(_usdt, 1_000_000);                    // eUSDT — 6 decimals
        _addToken(_dai,  1_000_000_000_000_000_000);    // eDAI  — 18 decimals
    }

    function _addToken(address _token, uint256 _fee) internal {
        if (_token == address(0)) revert InvalidAddress();
        if (_fee == 0) revert InvalidFee();
        if (acceptedTokens[_token]) revert TokenAlreadyAccepted();
        acceptedTokens[_token] = true;
        tokenFees[_token] = _fee;
        emit TokenAdded(_token, _fee);
    }

    function storeHash(
        bytes32 _hash,
        string calldata _label,
        string calldata _note,
        address _token
    ) external nonReentrant whenNotPaused {
        // Checks
        if (!acceptedTokens[_token]) revert TokenNotAccepted();
        if (bytes(_label).length == 0) revert LabelRequired();
        if (bytes(_label).length > 100) revert LabelTooLong();
        if (bytes(_note).length > 500) revert NoteTooLong();

        // Key binds hash to submitter — prevents front-running
        bytes32 recordKey = keccak256(abi.encode(msg.sender, _hash));
        if (records[recordKey].timestamp != 0) revert AlreadySealed();

        // Effects
        records[recordKey] = Record(_hash, msg.sender, block.timestamp, _label, _note, _token);
        emit HashStored(_hash, msg.sender, _token, block.timestamp, _label, _note);

        // Interactions
        IERC20(_token).safeTransferFrom(msg.sender, feeRecipient, tokenFees[_token]);
    }

    function getRecord(bytes32 _hash, address _submitter) external view returns (Record memory) {
        bytes32 recordKey = keccak256(abi.encode(_submitter, _hash));
        return records[recordKey];
    }

    // Admin
    function addToken(address _token, uint256 _fee) external onlyOwner {
        _addToken(_token, _fee);
    }

    function removeToken(address _token) external onlyOwner {
        acceptedTokens[_token] = false;
        delete tokenFees[_token];
        emit TokenRemoved(_token);
    }

    function setFeeRecipient(address _newRecipient) external onlyOwner {
        if (_newRecipient == address(0)) revert InvalidAddress();
        emit FeeRecipientChanged(feeRecipient, _newRecipient);
        feeRecipient = _newRecipient;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // Two-step ownership
    function transferOwnership(address _newOwner) external onlyOwner {
        if (_newOwner == address(0)) revert InvalidAddress();
        pendingOwner = _newOwner;
        emit OwnershipTransferStarted(owner, _newOwner);
    }

    function claimOwnership() external {
        if (msg.sender != pendingOwner) revert NotPendingOwner();
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}
