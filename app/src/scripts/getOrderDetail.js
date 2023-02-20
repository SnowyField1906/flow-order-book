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
import OrderBookV14 from 0xOrderBookV14

pub fun main(price: UFix64, isBid: Bool): OrderBookV14.Offer? {
    if isBid {
        return OrderBookV14.bidOffers[price]
    }
    return OrderBookV14.askOffers[price]
}
`