// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std-1.9.2/src/Test.sol";
import {NFT} from "../../src/Ecosystem_1/NFT.sol";

contract NFTPresaleTest is Test {
    address owner = address(99);
    // EOAs that are eligible for presale
    address public user1 = 0x0000000000000000000000000000000000000010;
    address public user2 = 0x0000000000000000000000000000000000000020;
    address public user3 = 0x0000000000000000000000000000000000000030;
    address public user4 = 0x0000000000000000000000000000000000000040;
    address public user5 = 0x0000000000000000000000000000000000000050;
    address public user6 = 0x0000000000000000000000000000000000000060;
    address public user7 = 0x0000000000000000000000000000000000000070;
    address public user8 = 0x0000000000000000000000000000000000000080;

    address public user9 = address(69); // not eligible for discount

    NFT public nft;
    bytes32 public merkleRoot = 0x4c1ef13b419daac1bb5111f29763df1e1a6a860e04f418295b63c3d85431aff9;

    function setUp() public {
        vm.deal(user1, 5 ether);

        vm.startPrank(owner);
        nft = new NFT("NFT", "NF", merkleRoot);
        vm.stopPrank();
    }

    function testClaim() public {
        // proof for user 1
        // proof generated in ./merkle-tree/createProof.ts
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = 0x3cc8c05c9ef6c07ca8d9a4d612a704f41724f0413a72ab2140b896b696b8deb7;
        proof[1] = 0x6f35e1ec2098b7f0b2c540e60bb67981702c548ec448988ab6443f7994f05b86;
        proof[2] = 0x6428a1d5194389c85395dbcdb092f07236e0e99e35bf17204440c264e516376f;

        vm.prank(user1);
        nft.mintWithDiscount{value: 1 ether}(proof, 0);
    }
}
