import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

pub fun main(): &{UFix64: OrderBookV6.Offer}? {
    return &OrderBookV6.offers as &{UFix64: OrderBookV6.Offer}?
}