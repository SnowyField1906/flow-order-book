import OrderBookV21 from 0xOrderBookV21
import OrderBookVaultV12 from 0xOrderBookVaultV12
import FungibleToken from 0xFungibleToken

transaction(price: UFix64, isBid: Bool) {
    prepare(signer: AuthAccount) {
        let storageCapability: Capability<&OrderBookV21.Admin{OrderBookV21.AdminPrivate}> = signer.getCapability<&OrderBookV21.Admin{OrderBookV21.AdminPrivate}>(OrderBookV21.AdminCapabilityPath)

        let listing = getAccount(0xOrderBookV21).getCapability<&OrderBookV21.Listing{OrderBookV21.ListingPublic}>(OrderBookV21.ListingPublicPath).borrow()!

        listing.cancelOrder(price: price, isBid: isBid, storageCapability: storageCapability)
    }

    execute {
    }
}