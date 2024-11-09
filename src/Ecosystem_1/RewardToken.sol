// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin-contracts-5.1.0/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin-contracts-5.1.0/token/ERC20/utils/SafeERC20.sol";
import {Ownable2Step} from "@openzeppelin-contracts-5.1.0/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin-contracts-5.1.0/access/Ownable.sol";

contract RewardToken is ERC20, Ownable2Step {
    using SafeERC20 for ERC20;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) Ownable(msg.sender) {}

    function mint(address recipient, uint256 amount) external onlyOwner {
        _mint(recipient, amount);
    }
}
