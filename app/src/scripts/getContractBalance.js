import * as fcl from "@onflow/fcl";

export default async function getContractBalance() {
    return fcl.query({
        cadence: CONTRACT_BALANCE,
    });
}

const CONTRACT_BALANCE = `
import OrderBookVaultV9 from 0xOrderBookVaultV9
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main() : {String: UFix64} {
    let tokenBundle = getAccount(0xOrderBookVaultV9).getCapability(OrderBookVaultV9.TokenPublicPath).borrow<&OrderBookVaultV9.TokenBundle{OrderBookVaultV9.TokenBundlePublic}>()!

    return {"Flow": tokenBundle.getFlowBalance(), "FUSD": tokenBundle.getFusdBalance()}
}
`