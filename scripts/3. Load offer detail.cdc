import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

pub fun main(id: UFix64): &OrderBookV6.Offer? {
    return &OrderBookV6.offers[id] as &OrderBookV6.Offer?
}