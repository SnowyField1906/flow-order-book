import OrderBookVaultV3 from 0xOrderBookVaultV3
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction {
    prepare(signer: AuthAccount) {
        if signer.borrow<&OrderBookVaultV3.TokenBundle>(from: OrderBookVaultV3.TokenStoragePath) == nil {
            signer.save(<- OrderBookVaultV3.createTokenBundle(admins: [signer.address]), to: OrderBookVaultV3.TokenStoragePath)
            signer.link<&OrderBookVaultV3.TokenBundle{OrderBookVaultV3.TokenBundlePublic}>(OrderBookVaultV3.TokenPublicPath, target: OrderBookVaultV3.TokenStoragePath)
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