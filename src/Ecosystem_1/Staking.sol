// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {RewardToken} from "../Ecosystem_1/RewardToken.sol";

import {IERC721} from "@openzeppelin-contracts-5.1.0/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin-contracts-5.1.0/token/ERC721/IERC721Receiver.sol";
import {IERC20} from "@openzeppelin-contracts-5.1.0/token/ERC20/IERC20.sol";

// receives NFT (possess it, only the same user can withdraw it)
// NFT stakers can withdraw 10 ERC20 tokens every 24h
contract Staking is IERC721Receiver {
    IERC721 private stakingNFToken;
    RewardToken private rewardToken;
    uint256 private constant REWARD_PRECISION = 18;

    uint256 public START_STAKING;
    uint256 public constant EPOCH_DURATION = 86_400; // 60*60*24 = 1 day in sec

    mapping(uint256 tokenId => uint256 stakedTime) tokenToTime;
    mapping(uint256 tokenId => address depositor) tokenToDepositor; // this allows to stake multiple tokens
    mapping(uint256 tokenId => mapping(uint256 epoch => bool claimed)) yieldClaimedByTokenByEpoch;

    error AlreadyClaimedYield();
    error NotCorrectNFT();
    error NotEligibleForYield(uint256 tokenId, address claimer);

    constructor(address addressStakingToken) {
        START_STAKING = block.timestamp;
        stakingNFToken = IERC721(addressStakingToken);
        rewardToken = new RewardToken("RewardToken", "RT"); // staking contract is owner
    }

    function claimYield(uint256 tokenId) external {
        // check if user is eligible
        address depositor = tokenToDepositor[tokenId];
        if (msg.sender != depositor) revert NotEligibleForYield(tokenId, msg.sender);

        // check if user already claimed for this period
        uint256 epoch = getCurrentEpoch();
        if (yieldClaimedByTokenByEpoch[tokenId][epoch]) revert AlreadyClaimedYield();

        // set to claimed
        yieldClaimedByTokenByEpoch[tokenId][epoch] = true;

        // mint tokens to user
        rewardToken.mint(msg.sender, 10 ** REWARD_PRECISION);
    }

    function onERC721Received(address operator, address from, uint256 id, bytes calldata data)
        external
        returns (bytes4)
    {
        // important safety to check only allow calls from our intended NFT
        if (msg.sender != address(stakingNFToken)) revert NotCorrectNFT();

        // uint8 voteId = abi.decode(data, (uint8));
        tokenToDepositor[id] = from; // from is the original owner
        tokenToTime[id] = block.timestamp;
        return IERC721Receiver.onERC721Received.selector;
    }

    function stake(uint256 tokenId) external {
        // CEI pattern
        // checks

        // interactions
        // using safeTransferFrom makes sure that if the transfer fails, the tx reverts
        // this fails if the msg.sender doesnt own the token
        // requires approve
        stakingNFToken.safeTransferFrom(msg.sender, address(this), tokenId);

        // effects
        tokenToTime[tokenId] = block.timestamp;
    }

    function unstake() external {}

    function getCurrentEpoch() private view returns (uint256) {
        uint256 difference = block.timestamp - START_STAKING;
        uint256 daysPassed = difference / EPOCH_DURATION; // assume integer division
        return daysPassed;
    }
}
