import OrderBookV18 from 0xOrderBookV18
import FlowFusdVaultV4 from 0xFlowFusdVaultV4
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction(quantity: UFix64, isBid: Bool) {
    let maker: Address

    prepare(signer: AuthAccount) {
        self.maker = signer.address

        let owed: {Address: OrderBookV18.Balance} = OrderBookV18.marketOrder(quantity: quantity, isBid: isBid)

        if isBid {
            let flowVaultRef = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)!

            owed.forEachKey(fun (key: Address): Bool {
                // transfer Flow from this order's to the makers
                let receiverFlowVault = getAccount(key).getCapability(/public/flowTokenReceiver)
                    .borrow<&{FungibleToken.Receiver}>()!
                receiverFlowVault.deposit(from: <- flowVaultRef.withdraw(amount: owed[key]!.flow))

                // transfer FUSD from contract's to this order 
                let userFusdVault = getAccount(self.maker).getCapability(/public/flowTokenReceiver)
                    .borrow<&{FungibleToken.Receiver}>()!
                userFusdVault.deposit(from: <- FlowFusdVaultV4.withdrawFusd(amount: owed[key]!.fusd, owner: key))

                return true
            })
        }
        else {
            let fusdVaultRef = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)!

            owed.forEachKey(fun (key: Address): Bool {
                // transfer FUSD from this order's to the makers
                let receiverFusdVault = getAccount(key).getCapability(/public/fusdTokenReceiver)
                    .borrow<&{FungibleToken.Receiver}>()!
                receiverFusdVault.deposit(from: <- fusdVaultRef.withdraw(amount: owed[key]!.fusd))

                // transfer Flow from contract's to this order
                let userFlowVault = getAccount(self.maker).getCapability(/public/flowTokenReceiver)
                    .borrow<&{FungibleToken.Receiver}>()!
                userFlowVault.deposit(from: <- FlowFusdVaultV4.withdrawFlow(amount: owed[key]!.flow, owner: key))

                return true
            })
        }
    }

    execute {
    }
}