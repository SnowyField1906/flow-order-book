import OrderBookV21 from 0xOrderBookV21

pub fun main(price: UFix64, isBid: Bool): &OrderBookV21.Order? {
    let listing = getAccount(0xOrderBookV21).getCapability<&OrderBookV21.Listing{OrderBookV21.ListingPublic}>(OrderBookV21.ListingPublicPath).borrow()

    if isBid {
        return &listing.bidOrders[price] as &OrderBookV21.Order?
    }
    return &listing.askOrders[price] as &OrderBookV21.Order?
}