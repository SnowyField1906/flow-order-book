import * as fcl from "@onflow/fcl";

export default async function getSortedIDs(isBid) {
    return fcl.query({
        cadence: SORTED_IDS(isBid),
    });
}


const SORTED_IDS = (isBid) => isBid ? `
import OrderBookV2 from 0xOrderBookV2
access(all) var keys: [UFix64] = []

pub fun inorder(key: UFix64?) {
    if (key == 0.0) {
        return;
    }
    
    inorder(key: OrderBookV2.bidTree.nodes[key!]?.right);
    keys.append(key!)
    inorder(key: OrderBookV2.bidTree.nodes[key!]?.left);
}

pub fun main(): [UFix64] {
    inorder(key: OrderBookV2.bidTree.root)
    
    return keys
}
` :
    `
import OrderBookV2 from 0xOrderBookV2
access(all) var keys: [UFix64] = []
    
pub fun inorder(key: UFix64?) {
    if (key == 0.0) {
        return;
    }

    inorder(key: OrderBookV2.askTree.nodes[key!]?.right);
    keys.append(key!)
    inorder(key: OrderBookV2.askTree.nodes[key!]?.left);
}
    
pub fun main(): [UFix64] {
    inorder(key: OrderBookV2.askTree.root)

    return keys
}
`