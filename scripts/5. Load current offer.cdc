import OrderBookV2 from "./../contracts/OrderBookV2.cdc"

pub fun main(): &OrderBookV2.Offer? {
    return &OrderBookV2.offers[OrderBookV2.idTree.root] as &OrderBookV2.Offer?
}