import * as fcl from "@onflow/fcl";

export default async function getCurrent() {
    return fcl.query({
        cadence: OFFER_DETAILS,
    });
}

const OFFER_DETAILS = `
import OrderBookV11 from 0xOrderBookV11

pub fun main(id: UFix64): OrderBookV11.Offer? {
    return OrderBookV11.offers[id]
}
`