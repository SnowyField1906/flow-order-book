import SimpleMarket from "./../contracts/SimpleMarket.cdc"

pub fun main(id: UInt32): [UInt32] {
    return [SimpleMarket.ids[id]?.left!, SimpleMarket.ids[id]?.right!]
}