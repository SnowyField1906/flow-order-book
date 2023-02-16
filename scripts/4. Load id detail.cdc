import OrderBookV7 from "./../contracts/OrderBookV7.cdc"

pub fun main(id: UFix64): OrderBookV7.Node? {
  
  return OrderBookV7.idTree.nodes[id]
}
 