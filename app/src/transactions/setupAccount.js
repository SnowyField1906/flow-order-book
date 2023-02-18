import * as fcl from "@onflow/fcl";

export default async function setupAccount() {
    return fcl.mutate({
        cadence: SETUP_ACCOUNT,
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        authorizations: [fcl.currentUser],
    });
}

const SETUP_ACCOUNT = `
import OrderBookVaultV9 from 0xOrderBookVaultV9
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction {
    prepare(signer: AuthAccount) {
        if signer.borrow<&OrderBookVaultV9.TokenBundle>(from: OrderBookVaultV9.TokenStoragePath) == nil {
            signer.save(<- OrderBookVaultV9.createTokenBundle(admins: [signer.address]), to: OrderBookVaultV9.TokenStoragePath)
            signer.link<&OrderBookVaultV9.TokenBundle{OrderBookVaultV9.TokenBundlePublic}>(OrderBookVaultV9.TokenPublicPath, target: OrderBookVaultV9.TokenStoragePath)
       }

        if signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) == nil {
            signer.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
            signer.link<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver, target: /storage/fusdVault)
            signer.link<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance, target: /storage/fusdVault)
        }

        if signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) == nil {
            signer.save(<-FlowToken.createEmptyVault(), to: /storage/flowTokenVault)
            signer.link<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver, target: /storage/flowTokenVault)
            signer.link<&FlowToken.Vault{FungibleToken.Balance}>(/public/flowTokenBalance, target: /storage/flowTokenVault)
        }
    }

    execute {
        log("Capability and Link created")
    }
}
`