import OrderBookV10 from "./../contracts/OrderBookV10.cdc"

pub fun main(): UFix64 {
    return OrderBookV10.idTree.root
}