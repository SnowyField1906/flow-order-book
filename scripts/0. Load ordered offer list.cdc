import OrderBookV7 from "./../contracts/OrderBookV7.cdc"

pub fun main(): &{UFix64: OrderBookV7.Offer}? {
    return &OrderBookV7.offers as &{UFix64: OrderBookV7.Offer}?
}