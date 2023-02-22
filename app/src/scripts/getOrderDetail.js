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
import OrderBookV16 from 0xOrderBookV16

pub fun main(price: UFix64, isBid: Bool): OrderBookV16.Offer? {
    if isBid {
        return OrderBookV16.bidOffers[price]
    }
    return OrderBookV16.askOffers[price]
}
`