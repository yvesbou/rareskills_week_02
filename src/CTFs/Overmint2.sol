// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import {ERC721} from "@openzeppelin-contracts-5.1.0/token/ERC721/ERC721.sol";
import {Address} from "@openzeppelin-contracts-5.1.0/utils/Address.sol";

contract Overmint2 is ERC721 {
    using Address for address;

    uint256 public totalSupply;

    constructor() ERC721("Overmint2", "AT") {}

    function mint() external {
        require(balanceOf(msg.sender) <= 3, "max 3 NFTs");
        totalSupply++;
        _mint(msg.sender, totalSupply);
    }

    function success(address account) external view returns (bool) {
        return balanceOf(account) == 5;
    }
}
