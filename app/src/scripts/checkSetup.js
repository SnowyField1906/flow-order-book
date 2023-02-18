import * as fcl from "@onflow/fcl";

export default async function checkSetup(address) {
    return fcl.query({
        cadence: CHECK_SETUP,
        args: (arg, t) => [
            arg(address, t.Address),
        ],
    });
}

const CHECK_SETUP = `
import OrderBookVaultV8 from 0xOrderBookVaultV8
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main(userAddress: Address): Bool {
    let signer = getAccount(userAddress)

    let vaultRef = signer.getCapability(OrderBookVaultV8.TokenPublicPath)!
        .borrow<&OrderBookVaultV8.TokenBundle{OrderBookVaultV8.TokenBundlePublic}>()
        ?? nil

    let receiverRef = signer.getCapability(/public/fusdReceiver)!
    .borrow<&FUSD.Vault{FungibleToken.Receiver}>()
        ?? nil

    let balanceRef = signer.getCapability(/public/fusdBalance)!
        .borrow<&FUSD.Vault{FungibleToken.Balance}>()
        ?? nil

    return (receiverRef != nil) && (balanceRef != nil) && (vaultRef != nil)
}
`