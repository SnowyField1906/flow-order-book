import OrderBookV10 from "./../contracts/OrderBookV10.cdc"

pub fun main(id: UFix64): OrderBookV10.Node? {
  
  return OrderBookV10.idTree.nodes[id]
}
 