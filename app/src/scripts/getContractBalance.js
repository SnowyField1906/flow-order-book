import * as fcl from "@onflow/fcl";

export default async function getContractBalance() {
    return fcl.query({
        cadence: CONTRACT_BALANCE,
    });
}

const CONTRACT_BALANCE = `
import OrderBookV18 from 0xOrderBookV18

pub fun main() : {String: UFix64} {
    return {"Flow": OrderBookV18.flowSupply, "FUSD": OrderBookV18.fusdSupply}
}
`