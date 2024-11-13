# Staking Ecosystem

Specs

- user can stake more than 1 NFT
- if staked 3 NFTs, they can withdraw 30 tokens every day

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
