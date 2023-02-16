import * as fcl from "@onflow/fcl";

export default async function cancelOrder(price, isBid) {
    return fcl.mutate({
        cadence: CANCEL_ORDER(price, isBid),
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        authorizations: [fcl.currentUser],
    });
}

const CANCEL_ORDER = (price, isBid) => `
import OrderBookV7 from 0xOrderBookV7
import OrderBookFlow from 0xOrderBookFlow
import OrderBookFusd from 0xOrderBookFusd
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction {
    let userVault: @FungibleToken.Vault
    let contractVault: @OrderBookFlow.Vault
    
    prepare(signer: AuthAccount) {
        if isBid {
            self.userVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            self.contractVault = signer.borrow<&OrderBookFlow.Vault>(from: OrderBookFlow.TokenStoragePath)
        }
        else {
            self.userVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            self.contractVault = signer.borrow<&OrderBookFusd.Vault>(from: OrderBookFusd.TokenStoragePath)
        }
    }

    execute {
        OrderBookV7.cancelOrder(price: UFix64(${price}), isBid: ${isBid}})

        let token <- self.contractVault.withdraw(amount: UFix64(${price}) as! @FungibleToken.Vault)
        self.userVault.deposit(from: <-token)
    }
}
`