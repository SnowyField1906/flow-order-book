import OrderBook from "../OrderBook.cdc"

access(all) var keys: [UFix64] = []

pub fun inorder(key: UFix64?) {
    if (key == 0.0) {
        return;
    }
    
    inorder(key: OrderBook.idTree.nodes[key!]?.left);
    keys.append(key!)
    inorder(key: OrderBook.idTree.nodes[key!]?.right);
}

pub fun main(): [UFix64] {
    inorder(key: OrderBook.idTree.root)
    
    return keys
}