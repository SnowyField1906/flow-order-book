import OrderBookV21 from 0xOrderBookV21

pub fun main(quantity: UFix64, isBid: Bool): UFix64 {
    let listing = getAccount(0xOrderBookV21).getCapability<&OrderBookV21.Listing{OrderBookV21.ListingPublic}>(OrderBookV21.ListingPublicPath).borrow()

    return listing!.marketPrice(quantity: quantity, isBid: isBid)
}