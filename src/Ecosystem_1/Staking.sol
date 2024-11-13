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

    uint256 public totalSupply = 0;
    uint256 public START_TIME_STAKING; // unix timestamp
    uint256 public constant EPOCH_DURATION = 1 days;
    uint256 public constant REWARD_RATE = 10 ** 19; // 10 token per day

    uint256 public periodFinished = 0;
    uint256 public lastUpdateTime = 0;
    uint256 public cumulativeRewardPerToken = 0;

    mapping(uint256 tokenId => uint256 cumulativeReward) tokenTolastUpdateCumulativeReward;
    mapping(uint256 tokenId => uint256 unclaimed) tokenToUnclaimedYield;
    mapping(uint256 tokenId => address depositor) tokenToDepositor; // this allows to stake multiple tokens (needed since transferred)

    error AlreadyClaimedYield();
    error NotCorrectNFT();
    error NotEligibleForYield(uint256 tokenId, address claimer);

    event YieldClaim(address indexed user, uint256 indexed tokenId, uint256 indexed amount);

    constructor(address addressStakingToken) {
        START_TIME_STAKING = block.timestamp;
        stakingNFToken = IERC721(addressStakingToken);
        rewardToken = new RewardToken("RewardToken", "RT"); // staking contract is owner
    }

    /// @notice A user can claim yield for a specific tokenId he/she deposited
    /// @dev Udpates the global state and tokenId specific state ()
    /// @param tokenId the nft for which the user wants to claim yield
    function claimYield(uint256 tokenId) external {
        // check if user is eligible
        address depositor = tokenToDepositor[tokenId];
        if (msg.sender != depositor) revert NotEligibleForYield(tokenId, msg.sender);

        _updateGlobalRewardState();
        _computeReward(tokenId);

        // mint tokens to user
        rewardToken.mint(msg.sender, tokenToUnclaimedYield[tokenId]);
        uint256 yield = tokenToUnclaimedYield[tokenId];
        tokenToUnclaimedYield[tokenId] = 0;

        // emit an event
        emit YieldClaim(msg.sender, tokenId, yield);
    }

    function onERC721Received(address operator, address from, uint256 id, bytes calldata data)
        external
        returns (bytes4)
    {
        // important safety to check only allow calls from our intended NFT
        if (msg.sender != address(stakingNFToken)) revert NotCorrectNFT();

        _updateGlobalRewardState();
        tokenToUnclaimedYield[id] = cumulativeRewardPerToken;

        tokenToDepositor[id] = from; // from is the original owner
        return IERC721Receiver.onERC721Received.selector;
    }

    function stake(uint256 tokenId) external {
        _updateGlobalRewardState();
        tokenTolastUpdateCumulativeReward[tokenId] = cumulativeRewardPerToken; // initiate with the current state (otherwise instant yield available)

        // effects
        tokenToDepositor[tokenId] = msg.sender; // from is the original owner

        // requires approve
        stakingNFToken.safeTransferFrom(msg.sender, address(this), tokenId);
    }

    function unstake() external {}

    // only update rewardPerToken and not lastUpdateTime (as it can have many tokens)
    // do update on time factor after updateRewards was called for every token
    function _updateGlobalRewardState() internal {
        cumulativeRewardPerToken = _computeNewAccruedRewardPerToken();
        lastUpdateTime = block.timestamp;
    }

    /// @notice updates the unclaimed yield for a staked nft
    /// @notice updates the total reward for a single nft based on the current timestamp
    /// @dev called after `_updateGlobalRewardState()`
    /// @param tokenId the nft for which book-keeping is updated
    function _computeReward(uint256 tokenId) internal {
        // get difference between updated global accrual and prev value for tokenId
        uint256 diff = cumulativeRewardPerToken - tokenTolastUpdateCumulativeReward[tokenId];
        // update latest update for particular nft
        tokenTolastUpdateCumulativeReward[tokenId] = cumulativeRewardPerToken;
        // new unclaimed yield based on new global state (time based accrual)
        tokenToUnclaimedYield[tokenId] += diff;
    }

    function _computeNewAccruedRewardPerToken() internal view returns (uint256) {
        return cumulativeRewardPerToken + ((block.timestamp - lastUpdateTime) * REWARD_RATE * 1e18) / totalSupply;
    }
}
