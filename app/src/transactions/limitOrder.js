import * as fcl from "@onflow/fcl";

export default async function limitOrder(price, amount, isBid) {
    return fcl.mutate({
        cadence: OFFER_DETAILS(price, amount, isBid),
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        authorizations: [fcl.currentUser],
    });
}

const OFFER_DETAILS = (price, amount, isBid) => `
import OrderBookV6 from 0xOrderBookV6
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction() {

    let maker: Address
    let sentVault: @FungibleToken.Vault

    prepare(acct: AuthAccount) {
        self.maker = acct.address
        
        if isBid {
            let vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow reference to the owner's Vault!")

            self.sentVault <- vaultRef.withdraw(amount: UFix64(${(amount)}))
        }
        else {
            let vaultRef = acct.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            ?? panic("Could not borrow reference to the owner's Vault!")

            self.sentVault <- vaultRef.withdraw(amount: UFix64(${(amount)}))
        }
    }

    execute {
        OrderBookV6.limitOrder(self.maker, price: UFix64(${(price)}), amount: UFix64(${(amount)}), isBid: ${(isBid)})
        let recipientAccount = getAccount(maker)

        if isBid {
            let recipientVault = recipientAccount.getCapability(/public/fusdReceiver)
                .borrow<&{FungibleToken.Receiver}>()
                ?? panic("Could not borrow receiver reference to the recipient's Vault!")
                
            receiverRef.deposit(from: <-self.sentVault)
        }
        else {
            let recipientVault = recipientAccount.getCapability(/public/flowTokenReceiver)
                .borrow<&{FungibleToken.Receiver}>()
                ?? panic("Could not borrow receiver reference to the recipient's Vault!")

            receiverRef.deposit(from: <-self.sentVault)
        }
    }
}
`