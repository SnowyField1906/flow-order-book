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
import OrderBookV10 from 0xOrderBookV10
import OrderBookVaultV8 from 0xOrderBookVaultV8
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction() {
    var userFusdVault: @FungibleToken.Vault
    var userFlowVault: @FungibleToken.Vault
    var contractVault: @OrderBookVault.TokenBundle

    prepare(signer: AuthAccount) {
        if signer.borrow<&OrderBookVaultV8.TokenBundle>(from: OrderBookVaultV8.TokenStoragePath) == nil {
            signer.save(<- OrderBookVaultV8.createTokenBundle(admins: [signer.address]), to: OrderBookVaultV8.TokenStoragePath)
            signer.link<&OrderBookVaultV8.TokenBundle{OrderBookVaultV8.TokenBundlePublic}>(OrderBookVaultV8.TokenBundlePublicPath, target: OrderBookVaultV8.TokenStoragePath)
       }
        if isBid {
            let vaultRef = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            self.userVault <- vaultRef.withdraw(amount: UFix64(${(quantity)}))
        }
        else {
            let vaultRef = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            self.userVault <- vaultRef.withdraw(amount: UFix64(${(quantity)}))
        }
        self.contractVault = signer.borrow<&OrderBookVault.TokenBundle>(from: OrderBookVault.TokenStoragePath)

    }

    execute {
        let payAmount = OrderBookV10.marketOrder(quantity: UFix64(${(quantity)}), isBid: ${(isBid)})

        if ${isBid} {
            let tokenVault <- self.userFlowVault.withdraw(amount: UFix64(${(quantity)}) as! @FlowToken.Vault
            self.contractVault.depositFlow(from: <-tokenVault)
        }
        else {
            let tokenVault <- self.userFusdVault.withdraw(amount: UFix64(${(quantity)}) as! @FUSD.Vault
            self.contractVault.depositFusd(from: <-tokenVault)
        }
    }
}
`