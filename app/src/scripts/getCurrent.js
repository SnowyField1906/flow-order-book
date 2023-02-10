import * as fcl from "@onflow/fcl";

export default async function getCurrent() {
    return fcl.query({
        cadence: OFFER_DETAILS,
    });
}

const OFFER_DETAILS = `
import OrderBookV2 from 0xOrderBookV2

pub fun main(id: UFix64): &OrderBookV2.Offer? {
    return &OrderBookV2.offers[id] as &OrderBookV2.Offer?
}
`