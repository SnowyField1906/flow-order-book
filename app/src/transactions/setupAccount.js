import * as fcl from "@onflow/fcl";

export default async function setupAccount() {
    return fcl.mutate({
        cadence: SETUP_ACCOUNT,
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        authorizations: [fcl.currentUser],
        limit: 200,
    });
}

const SETUP_ACCOUNT = `
import OrderBookV21 from 0xOrderBookV21
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction {
    prepare(signer: AuthAccount) {
        let flowReceiverCapability = signer.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        let fusdReceiverCapability = signer.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)

        signer.save(<-OrderBookV21.createAdmin(flowReceiverCapability: flowReceiverCapability, fusdReceiverCapability: fusdReceiverCapability), to: OrderBookV21.AdminStoragePath)
        signer.link<&OrderBookV21.Admin{OrderBookV21.AdminPublic}>(OrderBookV21.AdminPublicPath, target: OrderBookV21.AdminStoragePath)
        signer.link<&OrderBookV21.Admin{OrderBookV21.AdminPrivate}>(OrderBookV21.AdminCapabilityPath, target: OrderBookV21.AdminStoragePath)

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