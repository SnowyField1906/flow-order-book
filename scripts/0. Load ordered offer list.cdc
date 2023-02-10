import OrderBookV2 from "./../contracts/OrderBookV2.cdc"

pub fun main(): &{UFix64: OrderBookV2.Offer}? {
    return &OrderBookV2.offers as &{UFix64: OrderBookV2.Offer}?
}