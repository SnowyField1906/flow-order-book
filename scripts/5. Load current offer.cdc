import OrderBook from "./../contracts/OrderBook.cdc"

pub fun main(): &OrderBook.Offer? {
    return &OrderBook.offers[OrderBook.idTree.root] as &OrderBook.Offer?
}