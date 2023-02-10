import OrderBookV2 from "./../contracts/OrderBookV2.cdc"

pub fun main(id: UFix64): &OrderBookV2.Offer? {
    return &OrderBookV2.offers[id] as &OrderBookV2.Offer?
}