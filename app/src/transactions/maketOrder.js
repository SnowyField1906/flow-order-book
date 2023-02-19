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
import OrderBookV11 from 0xOrderBookV11
import OrderBookVaultV11 from 0xOrderBookVaultV11
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction() {
    var userFusdVault: @FungibleToken.Vault
    var userFlowVault: @FungibleToken.Vault
    var contractVault: @OrderBookVault.TokenBundle

    prepare(signer: AuthAccount) {
        if signer.borrow<&OrderBookVaultV11.TokenBundle>(from: OrderBookVaultV11.TokenStoragePath) == nil {
            signer.save(<- OrderBookVaultV11.createTokenBundle(admins: [signer.address]), to: OrderBookVaultV11.TokenStoragePath)
            signer.link<&OrderBookVaultV11.TokenBundle{OrderBookVaultV11.TokenBundlePublic}>(OrderBookVaultV11.TokenBundlePublicPath, target: OrderBookVaultV11.TokenStoragePath)
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
        let payAmount = OrderBookV11.marketOrder(quantity: UFix64(${(quantity)}), isBid: ${(isBid)})

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