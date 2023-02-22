import OrderBookV16 from 0xOrderBookV16
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction {
    prepare(signer: AuthAccount) {
        signer.save(<- create OrderBookV16.Admin(), to: OrderBookV16.AdminStoragePath)
        signer.link<&OrderBookV16.Admin{OrderBookV16.AdminPublic}>(OrderBookV16.AdminPublicPath, target: OrderBookV16.AdminStoragePath)
        signer.link<&OrderBookV16.Listing{OrderBookV16.ListingPublic}>(OrderBookV16.ListingPublicPath, target: OrderBookV16.AdminStoragePath)

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