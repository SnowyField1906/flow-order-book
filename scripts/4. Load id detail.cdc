import OrderBookV2 from "./../contracts/OrderBookV2.cdc"

pub fun main(id: UFix64): OrderBookV2.Node? {
  
  return OrderBookV2.idTree.nodes[id]
}
 