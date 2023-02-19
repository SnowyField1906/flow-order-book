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
import OrderBookV13 from 0xOrderBookV13

pub fun main(price: UFix64, isBid: Bool): OrderBookV13.Offer? {
    if isBid {
        return OrderBookV13.bidOffers[price]
    }
    return OrderBookV13.askOffers[price]
}
`