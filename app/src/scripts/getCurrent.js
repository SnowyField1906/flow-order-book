import * as fcl from "@onflow/fcl";

export default async function getCurrent() {
    return fcl.query({
        cadence: OFFER_DETAILS,
    });
}

const OFFER_DETAILS = `
import OrderBookV10 from 0xOrderBookV10

pub fun main(id: UFix64): OrderBookV10.Offer? {
    return OrderBookV10.offers[id]
}
`