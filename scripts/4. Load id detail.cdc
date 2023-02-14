import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

pub fun main(id: UFix64): OrderBookV6.Node? {
  
  return OrderBookV6.idTree.nodes[id]
}
 