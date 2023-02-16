import OrderBookV7 from "./../contracts/OrderBookV7.cdc"

pub fun main(): UFix64 {
    return OrderBookV7.idTree.root
}