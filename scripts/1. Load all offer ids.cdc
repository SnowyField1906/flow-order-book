import SimpleMarket from 0x05
// import BinarySearchOffers from 0x9d380238fdd484d7

pub fun main(): [UInt32] {
    let ids: [UInt32] = []

    var current = SimpleMarket.current
    while (current != 0) {
        ids.append(current)
        current = SimpleMarket.ids[current]!.right
    }

    return ids
}