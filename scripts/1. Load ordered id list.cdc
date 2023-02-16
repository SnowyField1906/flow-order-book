import OrderBookV7 from "../OrderBookV7.cdc"

pub fun main(): [UFix64] {
    return OrderBookV7.offers.keys
}