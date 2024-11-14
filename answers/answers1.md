- [ ] **Markdown file 1:** Answer these questions
  - [ ] How does ERC721A save gas?
  - [ ] Where does it add cost?

## Save gas

The gas savings are motivated by mitigating the immense gas costs at the launch of a new NFT collection where most users call `mint`. So the gas savings are related to minting.

### 1. remove duplicate storage

### 2. update balance of user at the end of the batch

If a user wants to buy 5 NFTs more, the storage is updated each time (5 times), going from 0 owned to 1 owned, and then from 1 owned to 2 owned, but all the the values are only transient. One can directly increment from 0 to 5 instead of re-writing to storage over and over again.

```Solidity
// normal ERC721 implementation
function _update(address to, uint256 tokenId, address auth) internal virtual returns (address)
  /// ...
  if (to != address(0)) {
      unchecked {
          _balances[to] += 1;
      }
  }
  /// ...
```

### 3. not writing to all storage slots for owners of a batch

Normally inside ERC721 each token mint would update the `_owners` mapping.

```Solidity
// normal ERC721 implementation
function _update(address to, uint256 tokenId, address auth) internal virtual returns (address)
  /// ...
  _owners[tokenId] = to;
  /// ...
```

## Add costs

### Additional transfer logic

Additional logic needs to be executed when transferring based on tokenId, since the ownership might not be revealed with the vanilla `ownerOf(uint256 tokenId)` call because storage could be empty inside `_owners[tokenId]` due to the batch mint logic and saving (3).

So in order to find the current owner of an NFT the implementation needs to add a loop that goes back to the first slot of a batch mint, where the current owner is revealed. In this loop each mint of the batch before the first mint of the batch needs to do a `sload`, which increases gas costs for transfers.

### Additonal deployed bytecode

Higher deployment costs due to more required logic.

## Overall judgement

In Ethereum Layer2s reduced gas costs significantly and removed a the blockspace bottle neck NFT collection releases would find so often.

Since this implementation increases costs of transfers, and gas costs on Layer2s are not a restrictive criteria, my judgement speaks against the use of ERC721A. But happy to learn otherwise.

To my judgement the article https://www.azuki.com/erc721a seems a bit outdated.

Current implementation seems to work with packed storage slots (32-byte) storing information of otherwise multiple slots.

```solidity
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return address(uint160(_packedOwnershipOf(tokenId)));
    }
```

```Solidity
    // Bits Layout:
    // - [0..159]   `addr`
    // - [160..223] `startTimestamp`
    // - [224]      `burned`
    // - [225]      `nextInitialized`
    // - [232..255] `extraData`
    mapping(uint256 => uint256) private _packedOwnerships;

    // Mapping owner address to address data.
    //
    // Bits Layout:
    // - [0..63]    `balance`
    // - [64..127]  `numberMinted`
    // - [128..191] `numberBurned`
    // - [192..255] `aux`
    mapping(address => uint256) private _packedAddressData;
```
