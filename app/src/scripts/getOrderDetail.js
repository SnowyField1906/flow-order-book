import * as fcl from "@onflow/fcl";

export default async function getOrderDetail(id, isBid) {
    return fcl.query({
        cadence: OFFER_DETAILS,
        args: (arg, t) => [
            arg(id, t.UFix64),
            arg(isBid, t.Bool),
        ],
    });
}

const OFFER_DETAILS = `
import OrderBookV18 from 0xOrderBookV18

pub fun main(price: UFix64, isBid: Bool): OrderBookV18.OrderDetails {
    let listing = getAccount(0xOrderBookV18).getCapability<&OrderBookV18.Listing{OrderBookV18.ListingPublic}>(OrderBookV18.ListingPublicPath).borrow()

    return listing!.orderDetails(price: price, isBid: isBid)
}
`