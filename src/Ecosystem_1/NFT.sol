// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {ERC721Royalty} from "@openzeppelin-contracts-5.1.0/token/ERC721/extensions/ERC721Royalty.sol";
import {Ownable2Step, Ownable} from "@openzeppelin-contracts-5.1.0/access/Ownable2Step.sol";
import {ERC721} from "@openzeppelin-contracts-5.1.0/token/ERC721/ERC721.sol";
import {BitMaps} from "@openzeppelin-contracts-5.1.0/utils/structs/BitMaps.sol";
import {MerkleProof} from "@openzeppelin-contracts-5.1.0/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin-contracts-5.1.0/utils/ReentrancyGuard.sol";

contract NFT is ReentrancyGuard, ERC721Royalty, Ownable2Step {
    uint256 private _tokenIdCounter = 8; // the first 8 ids (0,...7) are for merkletree
    bytes32 public merkleRoot;
    BitMaps.BitMap private _claimStatus;

    event MintWithDiscount(address indexed user, uint256 indexed index);
    event WithdrawalCompleted(address indexed owner, uint256 indexed amount);

    error AlreadyClaimed();
    error NotEnoughPaid();
    error MaxSupplyReached();

    constructor(string memory name_, string memory symbol_, bytes32 merkleRoot_)
        ERC721(name_, symbol_)
        Ownable(msg.sender)
    {
        _setDefaultRoyalty(msg.sender, 250);
        merkleRoot = merkleRoot_;
    }

    /**
     * - bitmap if claims claimed
     * - merkle tree stored to have claims
     */
    function mint() external payable {
        if (msg.value < 2 ether) revert NotEnoughPaid();
        _tokenIdCounter++;
        if (_tokenIdCounter == 1000) revert MaxSupplyReached();
        _safeMint(msg.sender, _tokenIdCounter);
    }

    function mintWithDiscount(bytes32[] calldata proof, uint256 index, uint256 amount) external payable {
        // check if already claimed
        if (BitMaps.get(_claimStatus, index)) revert AlreadyClaimed();

        // verify proof address, index, amount
        _verifyProof(proof, msg.sender, index, amount);

        if (msg.value < 1 ether) revert NotEnoughPaid(); // 50% discount

        // set claimed
        BitMaps.setTo(_claimStatus, index, true);

        // mint
        _safeMint(msg.sender, amount);

        emit MintWithDiscount(msg.sender, index);
    }

    function _verifyProof(bytes32[] calldata proof, address claimer, uint256 index, uint256 amount) private view {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(claimer, index, amount))));
        require(MerkleProof.verify(proof, merkleRoot, leaf));
    }

    function claimSales() external nonReentrant onlyOwner {
        uint256 collected = address(this).balance;
        (bool success,) = payable(msg.sender).call{value: collected}("");
        require(success, "Transfer failed");

        emit WithdrawalCompleted(msg.sender, collected);
    }
}
