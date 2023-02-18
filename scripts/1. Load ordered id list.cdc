import OrderBookV10 from "../OrderBookV10.cdc"

pub fun main(): [UFix64] {
    return OrderBookV10.offers.keys
}