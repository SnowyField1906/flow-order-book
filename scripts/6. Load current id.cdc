import OrderBookV2 from "./../contracts/OrderBookV2.cdc"

pub fun main(): UFix64 {
    return OrderBookV2.idTree.root
}