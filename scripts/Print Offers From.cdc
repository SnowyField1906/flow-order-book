// Print 0x1 NFTs

import SimpleMarket from 0x1

// Print the NFTs owned by account 0x1.
pub fun main() : [UFix64] {
    // Get the public account object for account 0x1
    let nftOwner = getAccount(0x1)

    // Find the public Receiver capability for their Collection
    let capability = nftOwner.getCapability<&SimpleMarket.User>(SimpleMarket.UserPublicPath)

    // borrow a reference from the capability
    let receiverRef = capability.borrow<&SimpleMarket.User>()
        ?? panic("Could not borrow the receiver reference")

    // Log the NFTs that they own as an array of IDs

    return receiverRef.getMade()
}
