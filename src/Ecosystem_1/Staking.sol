// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {RewardToken} from "../Ecosystem_1/RewardToken.sol";

import {IERC721} from "@openzeppelin-contracts-5.1.0/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin-contracts-5.1.0/token/ERC721/IERC721Receiver.sol";

// receives NFT (possess it, only the same user can withdraw it)
// NFT stakers can withdraw 10 ERC20 tokens every 24h
contract Staking is IERC721Receiver {
    IERC721 private stakingNFToken;
    RewardToken public rewardToken;

    uint256 public totalSupply = 0;
    uint256 public constant EPOCH_DURATION = 1 days;
    uint256 public constant REWARD_RATE = 10 ** 19; // 10 token per day

    uint256 public lastUpdateTime = 0;
    uint256 public cumulativeRewardPerToken = 0;

    mapping(uint256 tokenId => uint256 cumulativeReward) tokenTolastUpdateCumulativeReward;
    mapping(uint256 tokenId => uint256 unclaimed) tokenToUnclaimedYield;
    mapping(uint256 tokenId => address depositor) tokenToDepositor; // this allows to stake multiple tokens (needed since transferred)

    error AlreadyClaimedYield();
    error NotCorrectNFT();
    error NotAuthorisedForNFT();
    error NotEligibleForYield(uint256 tokenId, address claimer);

    event TokenStaked(address indexed user, uint256 indexed tokenId);
    event YieldClaim(address indexed user, uint256 indexed tokenId, uint256 indexed amount);

    constructor(address addressStakingToken) {
        stakingNFToken = IERC721(addressStakingToken);
        rewardToken = new RewardToken("RewardToken", "RT"); // staking contract is owner
    }

    /// @notice A user can claim yield for a specific tokenId he/she deposited
    /// @dev Udpates the global state and tokenId specific state ()
    /// @param tokenId the nft for which the user wants to claim yield
    function claimYield(uint256 tokenId) public {
        // check if user is eligible
        address depositor = tokenToDepositor[tokenId];
        if (msg.sender != depositor) revert NotEligibleForYield(tokenId, msg.sender);

        _updateGlobalRewardState();
        _computeReward(tokenId);

        // mint tokens to user
        rewardToken.mint(msg.sender, tokenToUnclaimedYield[tokenId]); // not safe mint & own implementation
        uint256 yield = tokenToUnclaimedYield[tokenId];
        tokenToUnclaimedYield[tokenId] = 0;

        // emit an event
        emit YieldClaim(msg.sender, tokenId, yield);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @dev data is no handled
    /// @param operator the account that executed the transfer to the staking account
    /// @param from the account that spended the nft
    /// @param id the identifier of the nft
    /// @return the onERC721Received.selector (4 bytes)
    function onERC721Received(address operator, address from, uint256 id) external returns (bytes4) {
        // important safety to check only allow calls from our intended NFT
        if (msg.sender != address(stakingNFToken)) revert NotCorrectNFT();

        // effects
        _updateGlobalRewardState();
        tokenTolastUpdateCumulativeReward[id] = cumulativeRewardPerToken;
        tokenToDepositor[id] = from; // from is the original owner
        totalSupply += 1;

        emit TokenStaked(from, id);
        return IERC721Receiver.onERC721Received.selector;
    }

    /// @notice A user can stake an nft
    /// @dev udpates global reward state
    /// @param tokenId the nft that is staked
    function stake(uint256 tokenId) external {
        _updateGlobalRewardState();
        tokenTolastUpdateCumulativeReward[tokenId] = cumulativeRewardPerToken; // initiate with the current state (otherwise instant yield available)

        // effects
        tokenToDepositor[tokenId] = msg.sender; // from is the original owner
        totalSupply += 1;

        // interactions
        // requires approve & fails if the user doesnt own it
        stakingNFToken.safeTransferFrom(msg.sender, address(this), tokenId);

        emit TokenStaked(msg.sender, tokenId);
    }

    /// @notice A user can un-stake an nft
    /// @dev claims yield before unstaking, since the user would loose access if the nft was sold afterwards
    /// @param tokenId the nft that is un-staked
    function unstake(uint256 tokenId) external {
        if (msg.sender != tokenToDepositor[tokenId]) {
            revert NotAuthorisedForNFT();
        }

        claimYield(tokenId); // not using safeMint

        totalSupply -= 1;
        delete tokenToDepositor[tokenId];
        delete tokenTolastUpdateCumulativeReward[tokenId];

        stakingNFToken.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    /// @notice Updates the global state for book-keeping
    /// @dev `_computeNewAccruedRewardPerToken` uses REWARD_RATE
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

    /// @notice Internal Function computes the reward since last update
    /// @dev only uses global (not-user specific) state variables
    /// @return the new total accrued reward that is claimable for each deposited nft since day 1
    function _computeNewAccruedRewardPerToken() internal view returns (uint256) {
        if (totalSupply == 0) return cumulativeRewardPerToken;
        return cumulativeRewardPerToken + (((block.timestamp - lastUpdateTime)) * REWARD_RATE / EPOCH_DURATION); // divide by totalSupply if a total allocation should be distributed
    }
}
