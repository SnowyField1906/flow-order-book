import SimpleMarket from "./../contracts/SimpleMarket.cdc"

pub fun main(id: UInt32): SimpleMarket.Node? {
    return SimpleMarket.ids[id]
}