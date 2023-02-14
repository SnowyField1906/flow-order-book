import OrderBookV6 from "../OrderBookV6.cdc"

access(all) var keys: [UFix64] = []

pub fun inorder(key: UFix64?) {
    if (key == 0.0) {
        return;
    }
    
    inorder(key: OrderBookV6.idTree.nodes[key!]?.left);
    keys.append(key!)
    inorder(key: OrderBookV6.idTree.nodes[key!]?.right);
}

pub fun main(): [UFix64] {
    inorder(key: OrderBookV6.idTree.root)
    
    return keys
}