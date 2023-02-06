import SimpleMarket from "./../contracts/SimpleMarket.cdc"

pub fun main(): &{UInt32: SimpleMarket.Offer}? {
    return &SimpleMarket.offers as &{UInt32: SimpleMarket.Offer}?
}