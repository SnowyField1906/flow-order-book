import * as fcl from "@onflow/fcl";

export default async function getOfferDetail(id, isBid) {
    return fcl.query({
        cadence: OFFER_DETAILS(id, isBid),
    });
}

const OFFER_DETAILS = (id, isBid) => `
import OrderBookV7 from 0xOrderBookV7

pub fun main(): OrderBookV7.Offer? {
    if ${isBid} {
        return OrderBookV7.bidOffers[UFix64(${id})]
    }
    return OrderBookV7.askOffers[UFix64(${id})]
}
`