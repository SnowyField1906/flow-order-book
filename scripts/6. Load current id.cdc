import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

pub fun main(): UFix64 {
    return OrderBookV6.idTree.root
}