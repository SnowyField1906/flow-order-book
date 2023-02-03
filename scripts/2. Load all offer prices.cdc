import SimpleMarket from 0x05
// import BinarySearchOffers from 0x9d380238fdd484d7

pub fun main(): [UFix64] {
    let ids: [UFix64] = []

    var current = SimpleMarket.current
    while (current != 0) {
        ids.append(SimpleMarket.getPrice(current))
        current = SimpleMarket.ids[current]!.right
    }

    return ids
}