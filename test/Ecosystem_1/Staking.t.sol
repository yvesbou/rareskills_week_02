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
}
