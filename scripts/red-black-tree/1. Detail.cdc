import RedBlackTree from "./../../contracts/RedBlackTree.cdc"

access(all) var keys: [RedBlackTree.Node] = []

pub fun inorder(key: UInt32?) {
  if (key == 0) {
    return;
  }
 
  inorder(key: RedBlackTree.nodes[key!]?.left);
  keys.append(RedBlackTree.nodes[key!]!)
  inorder(key: RedBlackTree.nodes[key!]?.right);
}

pub fun main(): [RedBlackTree.Node] {
  inorder(key: RedBlackTree.root)
  
  return keys
}
 