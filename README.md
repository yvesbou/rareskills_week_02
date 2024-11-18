# Rareskills Week 2

- [ ] **Markdown file 1:** Answer these questions
  - [x] How does ERC721A save gas?
  - [ ] Where does it add cost?
- [x] **Markdown file 2:** Besides the examples listed in the code and the reading, what might the wrapped NFT pattern be used for?
- [x] **Markdown file 3:** Revisit the solidity events tutorial. How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable? Explain how you would accomplish this if you were creating an NFT marketplace
- [ ] **Smart contract ecosystem 1:** Smart contract trio: NFT with merkle tree discount, ERC20 token, staking contract
  - [x] Create an ERC721 NFT with a supply of 1000.
  - [x] Include ERC 2918 royalty in your contract to have a reward rate of 2.5% for any NFT in the collection. Use the openzeppelin implementation.
  - [x] Addresses in a merkle tree can mint NFTs at a discount. Use the bitmap methodology described above. Use openzeppelin’s bitmap, don’t implement it yourself.
  - [x] Create an ERC20 contract that will be used to reward staking
  - [ ] Create and a third smart contract that can mint new ERC20 tokens and receive ERC721 tokens. A classic feature of NFTs is being able to receive them to stake tokens. Users can send their NFTs and withdraw 10 ERC20 tokens every 24 hours. Don’t forget about decimal places! The user can withdraw the NFT at any time. The smart contract must take possession of the NFT and only the user should be able to withdraw it. **IMPORTANT**: your staking mechanism must follow the sequence suggested in https://www.rareskills.io/post/erc721 under “Gas efficient staking, bypassing approval”
  - [x] Make the funds from the NFT sale in the contract withdrawable by the owner. Use Ownable2Step.
  - [ ] **Important:** Use a combination of unit tests and the gas profiler in foundry or hardhat to measure the gas cost of the various operations.

# Staking Ecosystem

# ERC721 onERC721Received Vulnerabilities

Always check msg.sender in onERC721Received
By default, anyone can call onERC721Received() with arbitrary parameters, fooling the contract into thinking it has received an NFT it doesn’t have. If your contract uses onERC721Received(), you must check that msg.sender is the NFT contract you expect!

safeTransfer reentrancy
SafeTransfer and \_safeMint hand execution control over to an external contract. Be careful when using safeTransfer to send an NFT to an arbitrary address, the receiver can put any logic they like the onERC721Received() function, possibly leading to reentrancy. If you properly defend against reentrancy, this does not need to be a concern.

safeTransfer denial of service
A malicious receiver can forcibly revert transactions by reverting inside onERC721Received() or by using a loop to consume all the gas. You should not assume that safeTransferFrom to an arbitrary address will succeed.

## Foundry with Soldeer Template

```shell
# to install the dependencies listed in foundry.toml
forge soldeer update
# build
forge build
# test
forge test

# remove dependencies
forge soldeer uninstall DEPENDENCY
# install dependencies
forge soldeer install @openzeppelin-contracts~5.0.2
```

https://book.getfoundry.sh/projects/soldeer

Check: https://soldeer.xyz/
Github: https://github.com/mario-eth/soldeer

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
