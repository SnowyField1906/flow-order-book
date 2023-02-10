import RedBlackTree from "./../../contracts/RedBlackTree.cdc"

access(all) var keys: [UInt32] = []

pub fun inorder(key: UInt32?) {
  if (key == 0) {
    return;
  }
 
  inorder(key: RedBlackTree.nodes[key!]?.left);
  keys.append(key!)
  inorder(key: RedBlackTree.nodes[key!]?.right);
}

pub fun main(): [UInt32] {
  inorder(key: RedBlackTree.root)
  
  return keys
}
 