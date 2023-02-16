import OrderBookV7 from "./../contracts/OrderBookV7.cdc"

pub fun main(): &OrderBookV7.Offer? {
    return &OrderBookV7.offers[OrderBookV7.idTree.root] as &OrderBookV7.Offer?
}