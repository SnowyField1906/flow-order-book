import SimpleMarket from "./../contracts/SimpleMarket.cdc"

pub fun main(): UInt32 {
    return SimpleMarket.current
}