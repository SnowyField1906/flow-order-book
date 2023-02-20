import OrderBookV14 from 0xOrderBookV14
import OrderBookVaultV12 from 0xOrderBookVaultV12
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction(price: UFix64, amount: UFix64, isBid: Bool) {
    let maker: Address

    prepare(signer: AuthAccount) {
        self.maker = signer.address

        let contractVault = signer.borrow<&OrderBookVaultV12.Administrator>(from: OrderBookVaultV12.TokenStoragePath)!
        let flowVaultRef = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)!
        let fusdVaultRef = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)!


        // is buying / bid
        if isBid {

          // doesn't exist a matching ask order
          if !OrderBookV14.askTree.exists(key: price) {

            // add this order with full amount
            OrderBookV14.limitOrder(self.maker, price: price, amount: amount, isBid: isBid)

            // transfer Flow from this order's to contract
            let userFlowVault <- flowVaultRef.withdraw(amount: price*amount) as! @FlowToken.Vault
            contractVault.depositFlow(from: <- userFlowVault)
          }

          // exists a matching ask order
          else {

            // ask order has enough FUSD amount for this order
            if OrderBookV14.askOffers[price]!.amount > amount {

              // decrease ask order's FUSD amount
              OrderBookV14.askOffers[price]!.changeAmount(amount: OrderBookV14.askOffers[price]!.amount - amount)

              // transfer Flow from this order's to ask
              let userFlowVault <- flowVaultRef.withdraw(amount: price*amount) as! @FlowToken.Vault
              let receiverFlowVault = getAccount(OrderBookV14.askOffers[price]!.maker).getCapability(/public/flowTokenReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
              receiverFlowVault.deposit(from: <- userFlowVault)

              // transfer FUSD from contract's to this order
              let contractFusdVault <- contractVault.withdrawFusd(amount: amount) as! @FUSD.Vault
              let userFusdVault = getAccount(self.maker).getCapability(/public/fusdReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
              userFusdVault.deposit(from: <- contractFusdVault)
            }

            else {

              // ask order doesn't have enough FUSD amount for this order
              if OrderBookV14.askOffers[price]!.amount < amount {

                // add this order with decreased amount
                OrderBookV14.limitOrder(self.maker, price: price, amount: amount - OrderBookV14.askOffers[price]!.amount, isBid: isBid)

                // transfer Flow from this order's to contract
                let userFlowVault1 <- flowVaultRef.withdraw(amount: price*(amount - OrderBookV14.askOffers[price]!.amount)) as! @FlowToken.Vault
                contractVault.depositFlow(from: <- userFlowVault1)

                // transfer Flow from this order's to ask
                let userFlowVault2 <- flowVaultRef.withdraw(amount: price*OrderBookV14.askOffers[price]!.amount) as! @FlowToken.Vault
                let receiverFlowVault = getAccount(OrderBookV14.askOffers[price]!.maker).getCapability(/public/flowTokenReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                receiverFlowVault.deposit(from: <- userFlowVault2)

                // transfer FUSD from contract's to this order
                let contractFusdVault <- contractVault.withdrawFusd(amount: OrderBookV14.askOffers[price]!.amount)
                let userFusdVault = getAccount(self.maker).getCapability(/public/fusdReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                userFusdVault.deposit(from: <- contractFusdVault)

              }

              // ask order has equal FUSD amount for this order
              else {
                  
                  // transfer Flow from this order's to ask
                  let userFlowVault <- flowVaultRef.withdraw(amount: price*amount) as! @FlowToken.Vault
                  let receiverFlowVault = getAccount(OrderBookV14.askOffers[price]!.maker).getCapability(/public/flowTokenReceiver)
                    .borrow<&{FungibleToken.Receiver}>()!
                  receiverFlowVault.deposit(from: <- userFlowVault)
  
                  // transfer FUSD from contract's to this order
                  let contractFusdVault <- contractVault.withdrawFusd(amount: amount)
                  let userFusdVault = getAccount(self.maker).getCapability(/public/fusdReceiver)
                    .borrow<&{FungibleToken.Receiver}>()!
                  userFusdVault.deposit(from: <- contractFusdVault)
              }
            // remove ask order
            OrderBookV14.askTree.remove(key: price)
            OrderBookV14.askOffers.remove(key: price)
            }
          }

        }

        // is selling / ask
        else {

          // doesn't exist a matching bid order
          if !OrderBookV14.bidTree.exists(key: price) {

            // add this order with full amount
            OrderBookV14.limitOrder(self.maker, price: price, amount: amount, isBid: isBid)

            // transfer FUSD from this order's to contract
            let userFusdVault <- fusdVaultRef.withdraw(amount: amount) as! @FUSD.Vault
            contractVault.depositFusd(from: <- userFusdVault)
          }

          // exists a matching bid order
          else {

            // bid order has enough Flow amount for this order
            if OrderBookV14.bidOffers[price]!.amount > amount {
              
              // decrease bid order's FUSD amount
              OrderBookV14.bidOffers[price]!.changeAmount(amount: OrderBookV14.bidOffers[price]!.amount - amount)

              // transfer FUSD from this order's to bid
              let userFusdVault <- fusdVaultRef.withdraw(amount: amount) as! @FUSD.Vault
              let receiverFusdVault = getAccount(OrderBookV14.bidOffers[price]!.maker).getCapability(/public/fusdReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
              receiverFusdVault.deposit(from: <- userFusdVault)

              // transfer Flow from contract's to this order
              let contractFlowVault <- contractVault.withdrawFlow(amount: amount*price)
              let userFlowVault = getAccount(self.maker).getCapability(/public/flowTokenReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
              userFlowVault.deposit(from: <- contractFlowVault)
            }

            else {

              // bid order doesn't have enough FUSD amount for this order
              if OrderBookV14.bidOffers[price]!.amount < amount {

                // add this order with decreased amount
                OrderBookV14.limitOrder(self.maker, price: price, amount: amount - OrderBookV14.bidOffers[price]!.amount, isBid: isBid)

                // transfer FUSD from this order's to contract
                let userFusdVault1 <- fusdVaultRef.withdraw(amount: amount - OrderBookV14.bidOffers[price]!.amount) as! @FUSD.Vault
                contractVault.depositFusd(from: <- userFusdVault1)

                // transfer FUSD from this order's to bid
                let userFusdVault2 <- fusdVaultRef.withdraw(amount: OrderBookV14.bidOffers[price]!.amount) as! @FUSD.Vault
                let receiverFusdVault = getAccount(OrderBookV14.bidOffers[price]!.maker).getCapability(/public/fusdReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                receiverFusdVault.deposit(from: <- userFusdVault2)

                // transfer Flow from contract's to this order
                let contractFlowVault <- contractVault.withdrawFlow(amount: price*OrderBookV14.bidOffers[price]!.amount)
                let userFlowVault = getAccount(self.maker).getCapability(/public/flowTokenReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                userFlowVault.deposit(from: <- contractFlowVault)
              }

              // bid order has equal FUSD amount for this order
              else {
                  
                // transfer FUSD from this order's to bid
                let userFusdVault <- fusdVaultRef.withdraw(amount: amount) as! @FUSD.Vault
                let receiverFusdVault = getAccount(OrderBookV14.bidOffers[price]!.maker).getCapability(/public/fusdReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                receiverFusdVault.deposit(from: <- userFusdVault)

                // transfer Flow from contract's to this order
                let contractFlowVault <- contractVault.withdrawFlow(amount: price*amount)
                let userFlowVault = getAccount(self.maker).getCapability(/public/flowTokenReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                userFlowVault.deposit(from: <- contractFlowVault)
              }
            // remove bid order
            OrderBookV14.bidTree.remove(key: price)
            OrderBookV14.bidOffers.remove(key: price)
            }
          }
        }
    }

    execute {
    }
}
 