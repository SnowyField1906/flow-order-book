import OrderBookV6 from "../OrderBookV6.cdc"

pub fun main(): [UFix64] {
    return OrderBookV6.offers.keys
}