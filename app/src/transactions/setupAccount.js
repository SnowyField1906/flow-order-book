import * as fcl from "@onflow/fcl";

export default async function setupAccount(address) {
    return fcl.mutate({
        cadence: SETUP_ACCOUNT(address),
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        authorizations: [fcl.currentUser],
    });
}

const SETUP_ACCOUNT = (address) => `
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction {
    prepare() {
        var signer = getAuthAccount(${address})

        if(signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) != nil) {
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