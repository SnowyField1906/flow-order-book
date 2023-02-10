import OrderBook from "../OrderBook.cdc"

pub fun main(): [UFix64] {
    return OrderBook.offers.keys
}