import * as fcl from "@onflow/fcl";

export default async function getOfferDetail(id, isBid) {
    return fcl.query({
        cadence: OFFER_DETAILS(id, isBid),
    });
}

const OFFER_DETAILS = (id, isBid) => `
import OrderBookV10 from 0xOrderBookV10

pub fun main(): OrderBookV10.Offer? {
    if ${isBid} {
        return OrderBookV10.bidOffers[UFix64(${id})]
    }
    return OrderBookV10.askOffers[UFix64(${id})]
}
`