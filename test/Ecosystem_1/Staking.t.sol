// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std-1.9.2/src/Test.sol";
import {NFT} from "../../src/Ecosystem_1/NFT.sol";
import {RewardToken} from "../../src/Ecosystem_1/RewardToken.sol";
import {Staking} from "../../src/Ecosystem_1/Staking.sol";

contract StakingTest is Test {
    address owner = address(99);

    // EOAs that are eligible for presale
    address public user1 = 0x0000000000000000000000000000000000000010;
    address public user2 = 0x0000000000000000000000000000000000000020;

    NFT public nft;
    RewardToken public token;

    Staking public staking;

    bytes32 public merkleRoot = 0x4c1ef13b419daac1bb5111f29763df1e1a6a860e04f418295b63c3d85431aff9;

    function setUp() public {
        vm.deal(user1, 5 ether);
        vm.deal(user2, 5 ether);

        vm.startPrank(owner);
        nft = new NFT("NFT", "NF", merkleRoot);
        staking = new Staking(address(nft));
        token = staking.rewardToken();
        vm.stopPrank();
    }

    /// only with one user, yield after 1 days
    function testStakeNFTAndReceiveYield() public {
        uint256 beforeReward = token.balanceOf(user1);
        assertEq(beforeReward, 0);

        uint256 tokenIdOfUser1 = 8;
        vm.prank(user1);
        nft.mint{value: 2 ether}(); // normal mint

        vm.prank(user1); // gas saving directly sending the nft to the contract
        nft.safeTransferFrom(user1, address(staking), tokenIdOfUser1); // first id for normal sale is 8

        // assert that the staking contract states have changed
        uint256 totalStaked = staking.totalSupply();
        assertEq(totalStaked, 1);
        // warp into the future and check if staking rewards accrued
        vm.warp(block.timestamp + 1 days);

        vm.prank(user1);
        staking.unstake(tokenIdOfUser1);

        totalStaked = staking.totalSupply();
        assertEq(totalStaked, 0);

        uint256 receivedReward = token.balanceOf(user1);
        assertEq(receivedReward, 1e19);
    }

    /// only with one user, yield after 2 days
    function testStakeNFTAndReceiveYieldAfterTwoDays() public {
        uint256 beforeReward = token.balanceOf(user1);
        assertEq(beforeReward, 0);

        uint256 tokenIdOfUser1 = 8;
        vm.prank(user1);
        nft.mint{value: 2 ether}(); // normal mint

        vm.prank(user1); // gas saving directly sending the nft to the contract
        nft.safeTransferFrom(user1, address(staking), tokenIdOfUser1); // first id for normal sale is 8

        // assert that the staking contract states have changed
        uint256 totalStaked = staking.totalSupply();
        assertEq(totalStaked, 1);
        // warp into the future and check if staking rewards accrued
        vm.warp(block.timestamp + 2 days);

        vm.prank(user1);
        staking.unstake(tokenIdOfUser1);

        totalStaked = staking.totalSupply();
        assertEq(totalStaked, 0);

        uint256 receivedReward = token.balanceOf(user1);
        assertEq(receivedReward, 2e19);
    }

    /// only with one user, yield after 0.5 days
    function testStakeNFTAndReceiveYieldAfterHalfADay() public {
        uint256 beforeReward = token.balanceOf(user1);
        assertEq(beforeReward, 0);

        uint256 tokenIdOfUser1 = 8;
        vm.prank(user1);
        nft.mint{value: 2 ether}(); // normal mint

        vm.prank(user1); // gas saving directly sending the nft to the contract
        nft.safeTransferFrom(user1, address(staking), tokenIdOfUser1); // first id for normal sale is 8

        // assert that the staking contract states have changed
        uint256 totalStaked = staking.totalSupply();
        assertEq(totalStaked, 1);
        // warp into the future and check if staking rewards accrued
        vm.warp(block.timestamp + 43_200);

        vm.prank(user1);
        staking.unstake(tokenIdOfUser1);

        totalStaked = staking.totalSupply();
        assertEq(totalStaked, 0);

        uint256 receivedReward = token.balanceOf(user1);
        assertEq(receivedReward, 5e18);
    }

    /// 2 users
    /// stake at the same time
    /// 1 day later, both have 10 tokens each
    function testTwoUserStakeFor1Day() public {
        uint256 tokenIdOfUser1 = 8;
        uint256 tokenIdOfUser2 = 9;

        /// buying NFT ///
        // user 1
        vm.prank(user1);
        nft.mint{value: 2 ether}(); // normal mint

        // user 2
        vm.prank(user2);
        nft.mint{value: 2 ether}(); // normal mint
        //////////////////

        ////// stake //////
        // user 1
        vm.prank(user1); // gas saving directly sending the nft to the contract
        nft.safeTransferFrom(user1, address(staking), tokenIdOfUser1); // first id for normal sale is 8

        // user 2
        vm.prank(user2); // gas saving directly sending the nft to the contract
        nft.safeTransferFrom(user2, address(staking), tokenIdOfUser2); // first id for normal sale is 8
        //////////////////

        // assert that the staking contract states have changed
        uint256 totalStaked = staking.totalSupply();
        assertEq(totalStaked, 2);
        // warp into the future and check if staking rewards accrued
        vm.warp(block.timestamp + 1 days);

        //// un-stake ////
        // user 1
        vm.prank(user1);
        staking.unstake(tokenIdOfUser1);
        // user 2
        vm.prank(user2);
        staking.unstake(tokenIdOfUser2);
        //////////////////

        totalStaked = staking.totalSupply();
        assertEq(totalStaked, 0);

        /// assert ///
        // user 1
        uint256 receivedRewardUser1 = token.balanceOf(user1);
        assertEq(receivedRewardUser1, 1e19);
        // user 2
        uint256 receivedRewardUser2 = token.balanceOf(user2);
        assertEq(receivedRewardUser2, 1e19);
    }

    /// user claims after 1 block
    function testClaimAfterOneBlock() public {
        uint256 beforeReward = token.balanceOf(user1);
        assertEq(beforeReward, 0);

        uint256 tokenIdOfUser1 = 8;
        vm.prank(user1);
        nft.mint{value: 2 ether}(); // normal mint

        vm.prank(user1); // gas saving directly sending the nft to the contract
        nft.safeTransferFrom(user1, address(staking), tokenIdOfUser1); // first id for normal sale is 8

        // assert that the staking contract states have changed
        uint256 totalStaked = staking.totalSupply();
        assertEq(totalStaked, 1);
        // warp into the future and check if staking rewards accrued
        vm.warp(block.timestamp + 12); // Advance time by 12 seconds
        vm.roll(block.number + 1); // Advance block by 1

        vm.prank(user1);
        staking.unstake(tokenIdOfUser1);

        totalStaked = staking.totalSupply();
        assertEq(totalStaked, 0);

        uint256 receivedReward = token.balanceOf(user1);
        // reward 12/86400 of 1e19
        assertEq(receivedReward, 1_388_888_888_888_888);
    }
}
