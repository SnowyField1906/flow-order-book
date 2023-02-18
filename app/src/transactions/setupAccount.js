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
import OrderBookVaultV8 from 0xOrderBookVaultV8
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction {
    prepare(signer: AuthAccount) {
        if signer.borrow<&OrderBookVaultV8.TokenBundle>(from: OrderBookVaultV8.TokenStoragePath) == nil {
            signer.save(<- OrderBookVaultV8.createTokenBundle(admins: [signer.address]), to: OrderBookVaultV8.TokenStoragePath)
            signer.link<&OrderBookVaultV8.TokenBundle{OrderBookVaultV8.TokenBundlePublic}>(OrderBookVaultV8.TokenPublicPath, target: OrderBookVaultV8.TokenStoragePath)
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