import OrderBookV18 from 0xOrderBookV18

access(all) var keys: [UFix64] = []
    
pub fun inorderAsk(key: UFix64?) {
    if (key == 0.0) {
        return;
    }

    inorderAsk(key: OrderBookV18.askTree.nodes[key!]?.right)
    keys.append(key!)
    inorderAsk(key: OrderBookV18.askTree.nodes[key!]?.left)
}

pub fun inorderBid(key: UFix64?) {
    if (key == 0.0) {
        return;
    }

    inorderBid(key: OrderBookV18.bidTree.nodes[key!]?.right)
    keys.append(key!)
    inorderBid(key: OrderBookV18.bidTree.nodes[key!]?.left)
}
    
pub fun main(isBid: Bool): [UFix64] {
    if isBid {
        inorderBid(key: OrderBookV18.bidTree.root)
    } else {
        inorderAsk(key: OrderBookV18.askTree.root)
    }

    return keys
}