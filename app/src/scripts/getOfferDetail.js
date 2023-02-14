import * as fcl from "@onflow/fcl";

export default async function getOfferDetail(id, isBid) {
    return fcl.query({
        cadence: OFFER_DETAILS(id, isBid),
    });
}

const OFFER_DETAILS = (id, isBid) => `
import OrderBookV6 from 0xOrderBookV6

pub fun main(): OrderBookV6.Offer? {
    if ${isBid} {
        return OrderBookV6.bidOffers[UFix64(${id})]
    }
    return OrderBookV6.askOffers[UFix64(${id})]
}
`