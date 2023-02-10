import OrderBook from "./../contracts/OrderBook.cdc"

pub fun main(): UFix64 {
    return OrderBook.idTree.root
}