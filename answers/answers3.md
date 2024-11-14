- [ ] **Markdown file 3:** Revisit the solidity events tutorial. How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable? Explain how you would accomplish this if you were creating an NFT marketplace

By indexing the events from the smart contract of the NFT collection. Each time a NFT changes ownership (also with mint (transfer from 0x0 to recipient)) a transfer event get emitted.

```solidity
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

// inside _udpate call
emit Transfer(from, to, tokenId);
```

Indexing means filling up a database with the values of the event and the timestamp & number of the block such that the ordering of the transactions is clear (also store other info like tx hash etc.)

To know the set of owned NFTs I would filter for all tx including my target user, and check for each tokenId if the latest tx was a receiving tx (to is equal to my target address)

Either you build your indexer yourself (based on a client or a wrapper library) or you use an existing indexing service and pay for that service.
