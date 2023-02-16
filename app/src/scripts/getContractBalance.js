import * as fcl from "@onflow/fcl";

export default async function getContractBalance() {
    return fcl.query({
        cadence: CONTRACT_BALANCE(),
    });
}

const CONTRACT_BALANCE = () => `
import OrderBookFlow from 0xOrderBookFlow
import OrderBookFusd from 0xOrderBookFusd
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main() : {String: UFix64} {


    return {"Flow": OrderBookFlow.getBalance(), "FUSD": OrderBookFusd.getBalance()}
}
`