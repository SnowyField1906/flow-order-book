import SimpleMarket from 0x05

pub fun main(id: UInt32): &SimpleMarket.Offer? {
    return &SimpleMarket.offers[id] as &SimpleMarket.Offer?
}