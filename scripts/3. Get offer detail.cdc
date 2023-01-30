import SimpleMarket from 0x01

pub fun main(id: UFix64): &SimpleMarket.Offer? {
    return &SimpleMarket.offers[id] as &SimpleMarket.Offer?
}