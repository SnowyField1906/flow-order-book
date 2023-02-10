import OrderBookV2 from "../OrderBookV2.cdc"

access(all) var keys: [UFix64] = []

pub fun inorder(key: UFix64?) {
    if (key == 0.0) {
        return;
    }
    
    inorder(key: OrderBookV2.idTree.nodes[key!]?.left);
    keys.append(key!)
    inorder(key: OrderBookV2.idTree.nodes[key!]?.right);
}

pub fun main(): [UFix64] {
    inorder(key: OrderBookV2.idTree.root)
    
    return keys
}