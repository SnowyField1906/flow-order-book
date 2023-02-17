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
import OrderBookVaultV3 from 0xOrderBookVaultV3
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction() {
    var userFusdVault: @FungibleToken.Vault
    var userFlowVault: @FungibleToken.Vault
    var contractVault: @OrderBookVault.TokenBundle

    prepare(signer: AuthAccount) {
        if signer.borrow<&OrderBookVaultV3.TokenBundle>(from: OrderBookVaultV3.TokenStoragePath) == nil {
            signer.save(<- OrderBookVaultV3.createTokenBundle(admins: [signer.address]), to: OrderBookVaultV3.TokenStoragePath)
            signer.link<&OrderBookVaultV3.TokenBundle{OrderBookVaultV3.TokenBundlePublic}>(OrderBookVaultV3.TokenBundlePublicPath, target: OrderBookVaultV3.TokenStoragePath)
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
        let payAmount = OrderBookV7.marketOrder(quantity: UFix64(${(quantity)}), isBid: ${(isBid)})

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