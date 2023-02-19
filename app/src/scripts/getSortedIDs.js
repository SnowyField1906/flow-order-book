import * as fcl from "@onflow/fcl";

export default async function getSortedIDs(isBid) {
    return fcl.query({
        cadence: SORTED_IDS,
        args: (arg, t) => [
            arg(isBid, t.Bool),
        ],
    });
}


const SORTED_IDS = `
import OrderBookV11 from 0xOrderBookV11

access(all) var keys: [UFix64] = []
    
pub fun inorderAsk(key: UFix64?) {
    if (key == 0.0) {
        return;
    }

    inorderAsk(key: OrderBookV11.askTree.nodes[key!]?.right)
    keys.append(key!)
    inorderAsk(key: OrderBookV11.askTree.nodes[key!]?.left)
}

pub fun inorderBid(key: UFix64?) {
    if (key == 0.0) {
        return;
    }

    inorderBid(key: OrderBookV11.bidTree.nodes[key!]?.right)
    keys.append(key!)
    inorderBid(key: OrderBookV11.bidTree.nodes[key!]?.left)
}
    
pub fun main(isBid: Bool): [UFix64] {
    if isBid {
        inorderBid(key: OrderBookV11.bidTree.root)
    } else {
        inorderAsk(key: OrderBookV11.askTree.root)
    }

    return keys
}
`