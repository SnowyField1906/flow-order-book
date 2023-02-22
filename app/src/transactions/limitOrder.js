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
import OrderBookV16 from 0xOrderBookV16
import FlowFusdVaultV4 from 0xFlowFusdVaultV4
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction(price: UFix64, amount: UFix64, isBid: Bool) {
    let maker: Address

    prepare(signer: AuthAccount) {
        self.maker = signer.address

        let flowVaultRef = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)!
        let fusdVaultRef = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)!

        // is buying / bid
        if isBid {

          // doesn't exist a matching ask order
          if !OrderBookV16.askTree.exists(key: price) {

            // add this order with full amount
            OrderBookV16.limitOrder(self.maker, price: price, amount: amount, isBid: isBid)

            // transfer Flow from this order's to contract
            let userFlowVault <- flowVaultRef.withdraw(amount: price*amount) as! @FlowToken.Vault
            FlowFusdVaultV4.depositFlow(from: <- userFlowVault, owner: self.maker)
          }

          // exists a matching ask order
          else {

            // ask order has enough FUSD amount for this order
            if OrderBookV16.askOffers[price]!.amount > amount {

              // decrease ask order's FUSD amount
              OrderBookV16.askOffers[price]!.changeAmount(amount: OrderBookV16.askOffers[price]!.amount - amount)

              // transfer Flow from this order's to ask
              let userFlowVault <- flowVaultRef.withdraw(amount: price*amount) as! @FlowToken.Vault
              let receiverFlowVault = getAccount(OrderBookV16.askOffers[price]!.maker).getCapability(/public/flowTokenReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
              receiverFlowVault.deposit(from: <- userFlowVault)

              // transfer FUSD from contract's to this order
              let contractFusdVault <- FlowFusdVaultV4.withdrawFusd(amount: amount, owner: OrderBookV16.askOffers[price]!.maker)
              let userFusdVault = getAccount(self.maker).getCapability(/public/fusdReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
              userFusdVault.deposit(from: <- contractFusdVault)
            }

            else {

              // ask order doesn't have enough FUSD amount for this order
              if OrderBookV16.askOffers[price]!.amount < amount {

                // add this order with decreased amount
                OrderBookV16.limitOrder(self.maker, price: price, amount: amount - OrderBookV16.askOffers[price]!.amount, isBid: isBid)

                // transfer Flow from this order's to contract
                let userFlowVault1 <- flowVaultRef.withdraw(amount: price*(amount - OrderBookV16.askOffers[price]!.amount)) as! @FlowToken.Vault
                FlowFusdVaultV4.depositFlow(from: <- userFlowVault1, owner: self.maker)

                // transfer Flow from this order's to ask
                let userFlowVault2 <- flowVaultRef.withdraw(amount: price*OrderBookV16.askOffers[price]!.amount) as! @FlowToken.Vault
                let receiverFlowVault = getAccount(OrderBookV16.askOffers[price]!.maker).getCapability(/public/flowTokenReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                receiverFlowVault.deposit(from: <- userFlowVault2)

                // transfer FUSD from contract's to this order
                let contractFusdVault <- FlowFusdVaultV4.withdrawFusd(amount: OrderBookV16.askOffers[price]!.amount, owner: OrderBookV16.askOffers[price]!.maker)
                let userFusdVault = getAccount(self.maker).getCapability(/public/fusdReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                userFusdVault.deposit(from: <- contractFusdVault)

              }

              // ask order has equal FUSD amount for this order
              else {
                  
                // transfer Flow from this order's to ask
                let userFlowVault <- flowVaultRef.withdraw(amount: price*amount) as! @FlowToken.Vault
                let receiverFlowVault = getAccount(OrderBookV16.askOffers[price]!.maker).getCapability(/public/flowTokenReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                receiverFlowVault.deposit(from: <- userFlowVault)

                // transfer FUSD from contract's to this order
                let contractFusdVault <- FlowFusdVaultV4.withdrawFusd(amount: amount, owner: OrderBookV16.askOffers[price]!.maker)
                let userFusdVault = getAccount(self.maker).getCapability(/public/fusdReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                userFusdVault.deposit(from: <- contractFusdVault)
              }

            // remove ask order
            OrderBookV16.askTree.remove(key: price)
            OrderBookV16.askOffers.remove(key: price)
            }
          }

        }

        // is selling / ask
        else {

          // doesn't exist a matching bid order
          if !OrderBookV16.bidTree.exists(key: price) {

            // add this order with full amount
            OrderBookV16.limitOrder(self.maker, price: price, amount: amount, isBid: isBid)

            // transfer FUSD from this order's to contract
            let userFusdVault <- fusdVaultRef.withdraw(amount: amount) as! @FUSD.Vault
            FlowFusdVaultV4.depositFusd(from: <- userFusdVault, owner: self.maker)
          }

          // exists a matching bid order
          else {

            // bid order has enough Flow amount for this order
            if OrderBookV16.bidOffers[price]!.amount > amount {
              
              // decrease bid order's FUSD amount
              OrderBookV16.bidOffers[price]!.changeAmount(amount: OrderBookV16.bidOffers[price]!.amount - amount)

              // transfer FUSD from this order's to bid
              let userFusdVault <- fusdVaultRef.withdraw(amount: amount) as! @FUSD.Vault
              let receiverFusdVault = getAccount(OrderBookV16.bidOffers[price]!.maker).getCapability(/public/fusdReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
              receiverFusdVault.deposit(from: <- userFusdVault)

              // transfer Flow from contract's to this order
              let contractFlowVault <- FlowFusdVaultV4.withdrawFlow(amount: amount*price, owner: OrderBookV16.bidOffers[price]!.maker)
              let userFlowVault = getAccount(self.maker).getCapability(/public/flowTokenReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
              userFlowVault.deposit(from: <- contractFlowVault)
            }

            else {

              // bid order doesn't have enough FUSD amount for this order
              if OrderBookV16.bidOffers[price]!.amount < amount {

                // add this order with decreased amount
                OrderBookV16.limitOrder(self.maker, price: price, amount: amount - OrderBookV16.bidOffers[price]!.amount, isBid: isBid)

                // transfer FUSD from this order's to contract
                let userFusdVault1 <- fusdVaultRef.withdraw(amount: amount - OrderBookV16.bidOffers[price]!.amount) as! @FUSD.Vault
                FlowFusdVaultV4.depositFusd(from: <- userFusdVault1, owner: self.maker)

                // transfer FUSD from this order's to bid
                let userFusdVault2 <- fusdVaultRef.withdraw(amount: OrderBookV16.bidOffers[price]!.amount) as! @FUSD.Vault
                let receiverFusdVault = getAccount(OrderBookV16.bidOffers[price]!.maker).getCapability(/public/fusdReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                receiverFusdVault.deposit(from: <- userFusdVault2)

                // transfer Flow from contract's to this order
                let contractFlowVault <- FlowFusdVaultV4.withdrawFlow(amount: price*OrderBookV16.bidOffers[price]!.amount, owner: OrderBookV16.bidOffers[price]!.maker)
                let userFlowVault = getAccount(self.maker).getCapability(/public/flowTokenReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                userFlowVault.deposit(from: <- contractFlowVault)
              }

              // bid order has equal FUSD amount for this order
              else {
                  
                  // transfer FUSD from this order's to bid
                  let userFusdVault <- fusdVaultRef.withdraw(amount: amount) as! @FUSD.Vault
                  let receiverFusdVault = getAccount(OrderBookV16.bidOffers[price]!.maker).getCapability(/public/fusdReceiver)
                    .borrow<&{FungibleToken.Receiver}>()!
                  receiverFusdVault.deposit(from: <- userFusdVault)
  
                  // transfer Flow from contract's to this order
                  let contractFlowVault <- FlowFusdVaultV4.withdrawFlow(amount: price*amount, owner: OrderBookV16.bidOffers[price]!.maker)
                  let userFlowVault = getAccount(self.maker).getCapability(/public/flowTokenReceiver)
                    .borrow<&{FungibleToken.Receiver}>()!
                  userFlowVault.deposit(from: <- contractFlowVault)
              }
              
            // remove bid order
            OrderBookV16.bidTree.remove(key: price)
            OrderBookV16.bidOffers.remove(key: price)
            }
          }
        }
    }

    execute {
    }
}
`