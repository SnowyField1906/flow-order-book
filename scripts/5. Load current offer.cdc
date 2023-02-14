import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

pub fun main(): &OrderBookV6.Offer? {
    return &OrderBookV6.offers[OrderBookV6.idTree.root] as &OrderBookV6.Offer?
}