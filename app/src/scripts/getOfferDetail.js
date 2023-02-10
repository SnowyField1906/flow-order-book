import * as fcl from "@onflow/fcl";

export default async function getOfferDetail(id, isBid) {
    return fcl.query({
        cadence: OFFER_DETAILS(id, isBid),
    });
}

const OFFER_DETAILS = (id, isBid) => `
import OrderBookV2 from 0xOrderBookV2

pub fun main(): &OrderBookV2.Offer? {
    if ${isBid} {
        return &OrderBookV2.bidOffers[UFix64(${id})] as &OrderBookV2.Offer?
    }
    return &OrderBookV2.askOffers[UFix64(${id})] as &OrderBookV2.Offer?
}
`