import OrderBookV18 from 0xOrderBookV18

pub fun main(price: UFix64, isBid: Bool): &OrderBookV18.Order? {
    let listing = getAccount(0xOrderBookV18).getCapability<&OrderBookV18.Listing{OrderBookV18.ListingPublic}>(OrderBookV18.ListingPublicPath).borrow()

    if isBid {
        return &listing.bidOrders[price] as &OrderBookV18.Order?
    }
    return &listing.askOrders[price] as &OrderBookV18.Order?
}