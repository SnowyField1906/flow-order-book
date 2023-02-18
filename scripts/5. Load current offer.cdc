import OrderBookV10 from "./../contracts/OrderBookV10.cdc"

pub fun main(): &OrderBookV10.Offer? {
    return &OrderBookV10.offers[OrderBookV10.idTree.root] as &OrderBookV10.Offer?
}