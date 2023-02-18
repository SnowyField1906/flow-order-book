import OrderBookV10 from 0xOrderBookV10
import OrderBookVaultV9 from 0xOrderBookVaultV9
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction(price: UFix64, amount: UFix64, isBid: Bool) {
    let maker: Address

    prepare(signer: AuthAccount) {
        self.maker = signer.address

        let contractVault = signer.borrow<&OrderBookVaultV9.TokenBundle>(from: OrderBookVaultV9.TokenStoragePath)!
        let flowVaultRef = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)!
        let fusdVaultRef = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)!


        // is buying / bid
        if isBid {

          // doesn't exist a matching ask order
          if !OrderBookV10.askTree.exists(key: price) {

            // add this order with full amount
            OrderBookV10.limitOrder(self.maker, price: price, amount: amount, isBid: isBid)

            // transfer Flow from this order's to contract
            let userFlowVault <- flowVaultRef.withdraw(amount: price*amount)
            contractVault.depositFlow(flowVault: <- userFlowVault, admin: self.maker)
          }

          // exists a matching ask order
          else {

            // ask order has enough FUSD amount for this order
            if OrderBookV10.askOffers[price]!.amount > amount {

              // decrease ask order's FUSD amount
              OrderBookV10.askOffers[price]!.changeAmount(amount: OrderBookV10.askOffers[price]!.amount - amount)

              // transfer Flow from this order's to ask
              let userFlowVault <- flowVaultRef.withdraw(amount: price*amount)
              let receiverFlowVault = getAccount(OrderBookV10.askOffers[price]!.maker).getCapability(/public/flowTokenReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
              receiverFlowVault.deposit(from: <- userFlowVault)

              // transfer FUSD from contract's to this order
              let contractFusdVault <- contractVault.withdrawFusd(amount: amount, admin: self.maker)
              let userFusdVault = getAccount(OrderBookV10.askOffers[price]!.maker).getCapability(/public/fusdReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
              userFusdVault.deposit(from: <- contractFusdVault)
            }

            else {

              // ask order doesn't have enough FUSD amount for this order
              if OrderBookV10.askOffers[price]!.amount < amount {

                // add this order with decreased amount
                OrderBookV10.limitOrder(self.maker, price: price, amount: amount - OrderBookV10.askOffers[price]!.amount, isBid: isBid)

                // transfer Flow from this order's to ask
                let userFlowVault <- flowVaultRef.withdraw(amount: price*OrderBookV10.askOffers[price]!.amount)
                let receiverFlowVault = getAccount(OrderBookV10.askOffers[price]!.maker).getCapability(/public/flowTokenReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                receiverFlowVault.deposit(from: <- userFlowVault)

                // transfer FUSD from contract's to this order
                let contractFusdVault <- contractVault.withdrawFusd(amount: OrderBookV10.askOffers[price]!.amount, admin: self.maker)
                let userFusdVault = getAccount(OrderBookV10.askOffers[price]!.maker).getCapability(/public/fusdReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                userFusdVault.deposit(from: <- contractFusdVault)

              }

            // ask order has equal FUSD amount for this order
            // remove ask order
            OrderBookV10.askTree.remove(key: price)
            OrderBookV10.askOffers.remove(key: price)
            }
          }

        }

        // is selling / ask
        else {

          // doesn't exist a matching bid order
          if !OrderBookV10.bidTree.exists(key: price) {

            // add this order with full amount
            OrderBookV10.limitOrder(self.maker, price: price, amount: amount, isBid: isBid)

            // transfer FUSD from this order's to contract
            let userFusdVault <- fusdVaultRef.withdraw(amount: amount)
            contractVault.depositFusd(fusdVault: <- userFusdVault, admin: self.maker)
          }

          // exists a matching bid order
          else {

            // bid order has enough Flow amount for this order
            if OrderBookV10.bidOffers[price]!.amount > amount {
              
              // decrease bid order's FUSD amount
              OrderBookV10.bidOffers[price]!.changeAmount(amount: OrderBookV10.bidOffers[price]!.amount - amount)

              // transfer FUSD from this order's to bid
              let userFusdVault <- fusdVaultRef.withdraw(amount: amount)
              let receiverFusdVault = getAccount(OrderBookV10.bidOffers[price]!.maker).getCapability(/public/fusdReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
              receiverFusdVault.deposit(from: <- userFusdVault)

              // transfer Flow from contract's to this order
              let contractFlowVault <- contractVault.withdrawFlow(amount: amount, admin: self.maker)
              let userFlowVault = getAccount(OrderBookV10.bidOffers[price]!.maker).getCapability(/public/flowTokenReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
              userFlowVault.deposit(from: <- contractFlowVault)
            }

            else {

              // bid order doesn't have enough FUSD amount for this order
              if OrderBookV10.bidOffers[price]!.amount < amount {

                // add this order with decreased amount
                OrderBookV10.limitOrder(self.maker, price: price, amount: amount - OrderBookV10.bidOffers[price]!.amount, isBid: isBid)

                // transfer FUSD from this order's to bid
                let userFusdVault <- fusdVaultRef.withdraw(amount: OrderBookV10.bidOffers[price]!.amount)
                let receiverFusdVault = getAccount(OrderBookV10.bidOffers[price]!.maker).getCapability(/public/fusdTokenReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                receiverFusdVault.deposit(from: <- userFusdVault)

                // transfer Flow from contract's to this order
                let contractFlowVault <- contractVault.withdrawFlow(amount: price*OrderBookV10.bidOffers[price]!.amount, admin: self.maker)
                let userFlowVault = getAccount(OrderBookV10.bidOffers[price]!.maker).getCapability(/public/flowReceiver)
                  .borrow<&{FungibleToken.Receiver}>()!
                userFlowVault.deposit(from: <- contractFlowVault)
              }

            // bid order has equal FUSD amount for this order
            // remove bid order
            OrderBookV10.bidTree.remove(key: price)
            OrderBookV10.bidOffers.remove(key: price)
            }
          }
        }
    }

    execute {
    }
}