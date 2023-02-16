import * as fcl from "@onflow/fcl";

export default async function getCurrent() {
    return fcl.query({
        cadence: OFFER_DETAILS,
    });
}

const OFFER_DETAILS = `
import OrderBookV7 from 0xOrderBookV7

pub fun main(id: UFix64): OrderBookV7.Offer? {
    return OrderBookV7.offers[id]
}
`