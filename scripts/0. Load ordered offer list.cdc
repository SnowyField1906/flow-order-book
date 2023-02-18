import OrderBookV10 from "./../contracts/OrderBookV10.cdc"

pub fun main(): &{UFix64: OrderBookV10.Offer}? {
    return &OrderBookV10.offers as &{UFix64: OrderBookV10.Offer}?
}