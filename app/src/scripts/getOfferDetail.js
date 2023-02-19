import * as fcl from "@onflow/fcl";

export default async function getOfferDetail(id, isBid) {
    return fcl.query({
        cadence: OFFER_DETAILS(id, isBid),
    });
}

const OFFER_DETAILS = (id, isBid) => `
import OrderBookV11 from 0xOrderBookV11

pub fun main(): OrderBookV11.Offer? {
    if ${isBid} {
        return OrderBookV11.bidOffers[UFix64(${id})]
    }
    return OrderBookV11.askOffers[UFix64(${id})]
}
`