import SimpleMarket from "./../contracts/SimpleMarket.cdc"

pub fun main(): [UInt32] {
    let ids: [UInt32] = []

    var current = SimpleMarket.current
    while (current != 0) {
        ids.append(current)
        current = SimpleMarket.ids[current]!.right
    }

    return ids
}