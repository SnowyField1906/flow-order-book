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
import OrderBookV21 from 0xOrderBookV21
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main(userAddress: Address): Bool {
    let signer = getAccount(userAddress)

    let adminRef = signer.getCapability(OrderBookV21.AdminPublicPath)!.borrow<&OrderBookV21.Admin{OrderBookV21.AdminPublic}>()
        ?? nil

    let receiverRef = signer.getCapability(/public/fusdReceiver)!
    .borrow<&FUSD.Vault{FungibleToken.Receiver}>()
        ?? nil

    let balanceRef = signer.getCapability(/public/fusdBalance)!
        .borrow<&FUSD.Vault{FungibleToken.Balance}>()
        ?? nil

    return (receiverRef != nil) && (balanceRef != nil) && (adminRef != nil)
}
`