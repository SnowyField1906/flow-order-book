import SimpleMarket from "./../contracts/SimpleMarket.cdc"

pub fun main(id: UInt32): &SimpleMarket.Offer? {
    return &SimpleMarket.offers[id] as &SimpleMarket.Offer?
}