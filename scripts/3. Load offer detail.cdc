import OrderBookV7 from "./../contracts/OrderBookV7.cdc"

pub fun main(id: UFix64): &OrderBookV7.Offer? {
    return &OrderBookV7.offers[id] as &OrderBookV7.Offer?
}