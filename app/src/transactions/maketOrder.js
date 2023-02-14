import * as fcl from "@onflow/fcl";

export default async function getOfferDetail() {
    return fcl.query({
        cadence: OFFER_DETAILS,
    });
}

const OFFER_DETAILS = `
import OrderBookV6 from 0xOrderBookV6

pub fun main(id: UFix64): &OrderBookV6.Offer? {
    return &OrderBookV6.offers[id] as &OrderBookV6.Offer?
}
`