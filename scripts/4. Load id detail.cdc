import OrderBook from "./../contracts/OrderBook.cdc"

pub fun main(id: UFix64): OrderBook.Node? {
  
  return OrderBook.idTree.nodes[id]
}
 