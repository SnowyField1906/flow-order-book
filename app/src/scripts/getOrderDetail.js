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
import OrderBookV11 from 0xOrderBookV11

pub fun main(price: UFix64, isBid: Bool): OrderBookV11.Offer? {
    if isBid {
        return OrderBookV11.bidOffers[price]
    }
    return OrderBookV11.askOffers[price]
}
`