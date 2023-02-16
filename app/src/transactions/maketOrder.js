import * as fcl from "@onflow/fcl";

export default async function limitOrder(quantity, isBid) {
    return fcl.mutate({
        cadence: LIMIT_ORDER(quantity, isBid),
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        authorizations: [fcl.currentUser],
    });
}

const LIMIT_ORDER = (quantity, isBid) => `
import OrderBookV7 from 0xOrderBookV7
import OrderBookVault from 0xOrderBookVault
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction() {
    let userFusdVault: @FungibleToken.Vault
    let userFlowVault: @FungibleToken.Vault
    let contractFusdVault: @OrderBookVault.Vault
    let contractFlowVault: @OrderBookVault.Vault

    prepare(acct: AuthAccount) {
        if isBid {
            let vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)

            self.userVault <- vaultRef.withdraw(amount: UFix64(${(quantity)}))
            self.contractVault = signer.borrow<&OrderBookVault.FlowVault>(from: /storage/orderBookFlowVault)
        }
        else {
            let vaultRef = acct.borrow<&FUSD.Vault>(from: /storage/fusdVault)

            self.userVault <- vaultRef.withdraw(amount: UFix64(${(quantity)}))
            self.contractVault = signer.borrow<&OrderBookVault.FUSDVault>(from: /storage/orderBookFUSDVault)
        }

    }

    execute {
        let payAmount = OrderBookV7.marketOrder(quantity: UFix64(${(quantity)}), isBid: ${(isBid)})

        if isBid {
            let tokenVault <- self.flowVault.withdraw(amount: UFix64(${(quantity)}) as! @FlowToken.Vault
            self.contractVault.withdraw(from: <-tokenVault)

        }
        else {
            let tokenVault <- self.fusdVault.withdraw(amount: UFix64(${(quantity)}) as! @FUSD.Vault
            self.contractVault.depositFUSD(from: <-tokenVault)
        }
    }
}
`