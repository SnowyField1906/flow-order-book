import OrderBookV7 from "../OrderBookV7.cdc"

access(all) var keys: [UFix64] = []

pub fun inorder(key: UFix64?) {
    if (key == 0.0) {
        return;
    }
    
    inorder(key: OrderBookV7.idTree.nodes[key!]?.left);
    keys.append(key!)
    inorder(key: OrderBookV7.idTree.nodes[key!]?.right);
}

pub fun main(): [UFix64] {
    inorder(key: OrderBookV7.idTree.root)
    
    return keys
}