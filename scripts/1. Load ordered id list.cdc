import OrderBookV2 from "../OrderBookV2.cdc"

pub fun main(): [UFix64] {
    return OrderBookV2.offers.keys
}