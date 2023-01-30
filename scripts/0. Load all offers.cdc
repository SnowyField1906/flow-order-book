import SimpleMarket from 0x01

pub fun main(): &{UFix64: SimpleMarket.Offer}? {
    return &SimpleMarket.offers as &{UFix64: SimpleMarket.Offer}?
}