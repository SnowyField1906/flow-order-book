import OrderBook from "./../contracts/OrderBook.cdc"

pub fun main(id: UFix64): &OrderBook.Offer? {
    return &OrderBook.offers[id] as &OrderBook.Offer?
}