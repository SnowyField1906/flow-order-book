import * as fcl from "@onflow/fcl";

export default async function getDepositedAmount(address) {
    return fcl.query({
        cadence: USER_DEPOSITED,
        args: (arg, t) => [
            arg(address, t.Address),
        ],
    });
}

const USER_DEPOSITED = `
import OrderBookVaultV11 from 0xOrderBookVaultV11
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main(userAddress: Address) : {String: UFix64} {
    let tokenBundle = getAccount(userAddress).getCapability(OrderBookVaultV11.TokenPublicPath).borrow<&OrderBookVaultV11.Administrator>()!

    return {"Flow": tokenBundle.flowBalance, "FUSD": tokenBundle.fusdBalance}
}
`