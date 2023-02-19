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
import OrderBookV13 from 0xOrderBookV13
import OrderBookVaultV12 from 0xOrderBookVaultV12
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction() {
    var userFusdVault: @FungibleToken.Vault
    var userFlowVault: @FungibleToken.Vault
    var contractVault: @OrderBookVault.TokenBundle

    prepare(signer: AuthAccount) {
        if signer.borrow<&OrderBookVaultV12.TokenBundle>(from: OrderBookVaultV12.TokenStoragePath) == nil {
            signer.save(<- OrderBookVaultV12.createTokenBundle(admins: [signer.address]), to: OrderBookVaultV12.TokenStoragePath)
            signer.link<&OrderBookVaultV12.TokenBundle{OrderBookVaultV12.TokenBundlePublic}>(OrderBookVaultV12.TokenBundlePublicPath, target: OrderBookVaultV12.TokenStoragePath)
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
        let payAmount = OrderBookV13.marketOrder(quantity: UFix64(${(quantity)}), isBid: ${(isBid)})

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