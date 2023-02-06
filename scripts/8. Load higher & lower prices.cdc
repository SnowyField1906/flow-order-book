import SimpleMarket from "./../contracts/SimpleMarket.cdc"

pub fun main(): [UInt16] {
    return [SimpleMarket.lowerPrices, SimpleMarket.higherPrices]
}