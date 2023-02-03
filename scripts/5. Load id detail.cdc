import SimpleMarket from 0x05

pub fun main(id: UInt32): SimpleMarket.Node? {
    return SimpleMarket.ids[id]
}