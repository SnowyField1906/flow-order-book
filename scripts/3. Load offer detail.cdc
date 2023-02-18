import OrderBookV10 from "./../contracts/OrderBookV10.cdc"

pub fun main(id: UFix64): &OrderBookV10.Offer? {
    return &OrderBookV10.offers[id] as &OrderBookV10.Offer?
}