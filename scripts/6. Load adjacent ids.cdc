import SimpleMarket from 0x05

pub fun main(id: UInt32): [UInt32] {
    return [SimpleMarket.ids[id]?.left!, SimpleMarket.ids[id]?.right!]
}