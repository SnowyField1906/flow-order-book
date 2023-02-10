import OrderBook from "./../contracts/OrderBook.cdc"

pub fun main(): &{UFix64: OrderBook.Offer}? {
    return &OrderBook.offers as &{UFix64: OrderBook.Offer}?
}