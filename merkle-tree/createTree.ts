import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import fs from "fs";

// (1) list of the beneficiaries
const values = [
  ["0x0000000000000000000000000000000000000010", "0"],
  ["0x0000000000000000000000000000000000000020", "1"],
  ["0x0000000000000000000000000000000000000030", "2"],
  ["0x0000000000000000000000000000000000000040", "3"],
  ["0x0000000000000000000000000000000000000050", "4"],
  ["0x0000000000000000000000000000000000000060", "5"],
  ["0x0000000000000000000000000000000000000070", "6"],
  ["0x0000000000000000000000000000000000000080", "7"],
];

// (2) use the OZ library for creating the tree
const tree = StandardMerkleTree.of(values, ["address", "uint256"]);

// (3)
console.log("Merkle Root:", tree.root);

// (4)
fs.writeFileSync("tree.json", JSON.stringify(tree.dump()));
