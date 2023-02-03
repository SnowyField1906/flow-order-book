import SimpleMarket from 0x05

pub fun main(): &{UInt32: SimpleMarket.Offer}? {
    return &SimpleMarket.offers as &{UInt32: SimpleMarket.Offer}?
}