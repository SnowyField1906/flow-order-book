import SimpleMarket from "./../contracts/SimpleMarket.cdc"

pub fun main(): [UInt32] {
    let ids: [UInt32] = []

    var current = SimpleMarket.current
    fun inorder(_ current: UInt32) {
        if current == 0 {
            return
        }
        inorder(SimpleMarket.offers(current).left)
        ids.append(SimpleMarket.offers(current))
        inorder(SimpleMarket.offers(current).left)
    }

    return ids
}