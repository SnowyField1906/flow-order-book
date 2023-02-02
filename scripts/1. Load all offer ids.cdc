import SimpleMarketv2 from 0x9d380238fdd484d7
// import BinarySearchOffers from 0x9d380238fdd484d7

pub fun main(): [UInt32] {
    let offers: [UInt32] = []
    SimpleMarketv2.inorderTraversal(offers, SimpleMarketv2.root)

    return offers
}