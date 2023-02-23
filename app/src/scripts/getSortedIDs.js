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
import OrderBookV21 from 0xOrderBookV21

access(all) var keys: [UFix64] = []
access(all) let listing = getAccount(0xOrderBookV21).getCapability(OrderBookV21.ListingPublicPath).borrow<&{OrderBookV21.ListingPublic}>()!

pub fun inorderAsk(key: UFix64?) {
    if (key == 0.0) {
        return;
    }

    inorderAsk(key: listing.askTree.nodes[key!]?.right)
    keys.append(key!)
    inorderAsk(key: listing.askTree.nodes[key!]?.left)
}

pub fun inorderBid(key: UFix64?) {
    if (key == 0.0) {
        return;
    }

    inorderBid(key: listing.bidTree.nodes[key!]?.right)
    keys.append(key!)
    inorderBid(key: listing.bidTree.nodes[key!]?.left)
}
    
pub fun main(isBid: Bool): [UFix64] {
    if isBid {
        inorderBid(key: listing.bidTree.root)
    } else {
        inorderAsk(key: listing.askTree.root)
    }

    return keys
}
`