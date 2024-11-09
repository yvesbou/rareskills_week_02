// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {ERC721Royalty} from "@openzeppelin-contracts-5.1.0/token/ERC721/extensions/ERC721Royalty.sol";

// un-used
import {ERC721} from "@openzeppelin-contracts-5.1.0/token/ERC721/ERC721.sol";
import {IERC721} from "@openzeppelin-contracts-5.1.0/token/ERC721/IERC721.sol";
import {IERC721Metadata} from "@openzeppelin-contracts-5.1.0/interfaces/IERC721Metadata.sol";
import {ERC2981} from "@openzeppelin-contracts-5.1.0/token/common/ERC2981.sol";
import {IERC2981} from "@openzeppelin-contracts-5.1.0/interfaces/IERC2981.sol";

contract NFT is ERC721Royalty {
    uint256 private _tokenIdCounter;

    error MaxSupplyReached();

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        _setDefaultRoyalty(msg.sender, 250);
    }

    // TODO: add merkle tree
    function mint() external {
        _tokenIdCounter++;
        if (_tokenIdCounter == 1000) revert MaxSupplyReached();
        _safeMint(msg.sender, _tokenIdCounter);
    }
}
