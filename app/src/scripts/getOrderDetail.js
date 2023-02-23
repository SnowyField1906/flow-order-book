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
import OrderBookV21 from 0xOrderBookV21

pub fun main(price: UFix64, isBid: Bool): OrderBookV21.OrderDetails? {
    let listing = getAccount(0xOrderBookV21).getCapability<&OrderBookV21.Listing{OrderBookV21.ListingPublic}>(OrderBookV21.ListingPublicPath).borrow()

    return listing!.orderDetails(price: price, isBid: isBid)
}
`