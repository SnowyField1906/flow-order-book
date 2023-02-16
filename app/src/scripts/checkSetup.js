import * as fcl from "@onflow/fcl";

export default async function checkSetup(address) {
    return fcl.query({
        cadence: CHECK_SETUP(address),
    });
}

const CHECK_SETUP = (address) => `
import OrderBookFlow from 0xOrderBookFlow
import OrderBookFusd from 0xOrderBookFusd
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main(): Bool {
    let signer = getAccount(${address})
    let receiverRef = signer.getCapability(/public/fusdReceiver)!
    .borrow<&FUSD.Vault{FungibleToken.Receiver}>()
        ?? nil

    let balanceRef = signer.getCapability(/public/fusdBalance)!
        .borrow<&FUSD.Vault{FungibleToken.Balance}>()
        ?? nil

    let flowRef = signer.getCapability(OrderBookFlow.TokenPublicReceiverPath)!
        .borrow<&OrderBookFlow.Vault{FungibleToken.Receiver}>()
        ?? nil

    let fusdRef = signer.getCapability(OrderBookFusd.TokenPublicReceiverPath)!
        .borrow<&OrderBookFusd.Vault{FungibleToken.Receiver}>()
        ?? nil

    return (receiverRef != nil) && (balanceRef != nil) && (flowRef != nil) && (fusdRef != nil)
}
`