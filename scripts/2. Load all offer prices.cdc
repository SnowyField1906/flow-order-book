import SimpleMarket from "./../contracts/SimpleMarket.cdc"

pub fun main(): [UFix64] {
    let ids: [UFix64] = []

    var current = SimpleMarket.current
    while (current != 0) {
        ids.append(SimpleMarket.getPrice(current))
        current = SimpleMarket.ids[current]!.right
    }

    return ids
}