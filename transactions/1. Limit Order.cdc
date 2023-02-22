import OrderBookV16 from 0xOrderBookV16
import OrderBookVaultV12 from 0xOrderBookVaultV12
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction(price: UFix64, amount: UFix64, isBid: Bool) {
    prepare(signer: AuthAccount) {
        let storageCapability = signer.borrow<&Admin>(from: AdminStoragePath)!.getCapability<&Admin{AdminPrivate}>(AdminPrivatePath)
        let flowVaultRef = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
        let fusdVaultRef = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)

        let Listing = getAccount(0xOrderBookV16).getCapability<&OrderBookV16.Listing{OrderBookV16.ListingPublic}>(OrderBookV16.ListingPublicPath).borrow()!

        Listing.limitOrder(addr: signer.address, price: price, amount: amount, isBid: isBid, storageCapability: storageCapability, flowVaultRef: flowVaultRef, fusdVaultRef: fusdVaultRef)

    }

    execute {
    }
}
 