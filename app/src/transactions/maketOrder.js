import * as fcl from "@onflow/fcl";

export default async function marketOrder(quantity, isBid) {
    return fcl.mutate({
        cadence: MARKET_ORDER,
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        authorizations: [fcl.currentUser],
        args: (arg, t) => [
            arg(quantity.toString(), t.UFix64),
            arg(isBid, t.Bool),
        ],
        limit: 1000,
    });
}

const MARKET_ORDER = `
import OrderBookV16 from 0xOrderBookV16
import FlowFusdVaultV4 from 0xFlowFusdVaultV4
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction(quantity: UFix64, isBid: Bool) {

    prepare(signer: AuthAccount) {
        let owed: {Address: OrderBookV16.Balance} = OrderBookV16.marketOrder(quantity: quantity, isBid: isBid)

        if isBid {
            let flowVaultRef = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)!

            owed.forEachKey(fun (key: Address): Bool {
                // transfer Flow from this order's to the makers
                let receiverFlowVault = getAccount(key).getCapability(/public/flowTokenReceiver)
                    .borrow<&{FungibleToken.Receiver}>()!
                receiverFlowVault.deposit(from: <- flowVaultRef.withdraw(amount: owed[key]!.flow))

                // transfer FUSD from contract's to this order 
                let userFusdVault = getAccount(signer.address).getCapability(/public/fusdReceiver)
                    .borrow<&{FungibleToken.Receiver}>()!
                userFusdVault.deposit(from: <- FlowFusdVaultV4.withdrawFusd(amount: owed[key]!.fusd, owner: key))

                return true
            })
        }
        else {
            let fusdVaultRef = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)!

            owed.forEachKey(fun (key: Address): Bool {
                // transfer FUSD from this order's to the makers
                let receiverFusdVault = getAccount(key).getCapability(/public/fusdReceiver)
                    .borrow<&{FungibleToken.Receiver}>()!
                receiverFusdVault.deposit(from: <- fusdVaultRef.withdraw(amount: owed[key]!.fusd))

                // transfer Flow from contract's to this order
                let userFlowVault = getAccount(signer.address).getCapability(/public/flowTokenReceiver)
                    .borrow<&{FungibleToken.Receiver}>()!
                userFlowVault.deposit(from: <- FlowFusdVaultV4.withdrawFlow(amount: owed[key]!.flow, owner: key))

                return true
            })
        }
    }

    execute {
    }
}
`