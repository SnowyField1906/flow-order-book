import OrderBookV10 from "../OrderBookV10.cdc"

access(all) var keys: [UFix64] = []

pub fun inorder(key: UFix64?) {
    if (key == 0.0) {
        return;
    }
    
    inorder(key: OrderBookV10.idTree.nodes[key!]?.left);
    keys.append(key!)
    inorder(key: OrderBookV10.idTree.nodes[key!]?.right);
}

pub fun main(): [UFix64] {
    inorder(key: OrderBookV10.idTree.root)
    
    return keys
}