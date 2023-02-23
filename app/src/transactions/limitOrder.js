import * as fcl from "@onflow/fcl";

export default async function limitOrder(price, amount, isBid) {
  return fcl.mutate({
    cadence: LIMIT_ORDER,
    proposer: fcl.currentUser,
    payer: fcl.currentUser,
    authorizations: [fcl.currentUser],
    args: (arg, t) => [
      arg(price.toString(), t.UFix64),
      arg(amount.toString(), t.UFix64),
      arg(isBid, t.Bool),
    ],
    limit: 1000,
  });
}

const LIMIT_ORDER = `
import OrderBookV18 from 0xOrderBookV18
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction(price: UFix64, amount: UFix64, isBid: Bool) {
    prepare(signer: AuthAccount) {
        let storageCapability: Capability<&OrderBookV18.Admin{OrderBookV18.AdminPrivate}> = signer.getCapability<&OrderBookV18.Admin{OrderBookV18.AdminPrivate}>(OrderBookV18.AdminCapabilityPath)
        let flowVaultRef = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)!
        let fusdVaultRef = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)!

        let listing = getAccount(0xOrderBookV18).getCapability<&OrderBookV18.Listing{OrderBookV18.ListingPublic}>(OrderBookV18.ListingPublicPath).borrow()!

        listing.limitOrder(addr: signer.address, price: price, amount: amount, isBid: isBid, storageCapability: storageCapability, flowVaultRef: flowVaultRef, fusdVaultRef: fusdVaultRef)
    }

    execute {
    }
}
`