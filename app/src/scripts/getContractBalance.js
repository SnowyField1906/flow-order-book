import * as fcl from "@onflow/fcl";

export default async function getContractBalance() {
    return fcl.query({
        cadence: CONTRACT_BALANCE,
    });
}

const CONTRACT_BALANCE = `
import OrderBookV21 from 0xOrderBookV21

pub fun main() : {String: UFix64} {
    return {"Flow": OrderBookV21.flowSupply, "FUSD": OrderBookV21.fusdSupply}
}
`