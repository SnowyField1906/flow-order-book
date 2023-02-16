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
import OrderBookV7 from 0xOrderBookV7
import OrderBookFlow from 0xOrderBookFlow
import OrderBookFusd from 0xOrderBookFusd
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction() {
    let maker: Address
    
    let userFlowVaultRef: &FlowToken.Vault
    let userFusdVaultRef: &FUSD.Vault
    let contractFlowVault: &OrderBookFlow.Vault
    let contractFusdVault: &OrderBookFusd.Vault

    prepare(signer: AuthAccount) {
        self.maker = signer.address
        
        self.userFlowVaultRef = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
        self.userFusdVaultRef = signer.borrow<&FUSD.Vault>(from: /storage/contractFusdVault)

        self.contractFlowVault = signer.borrow<&OrderBookFlow.Vault>(from: OrderBookFlow.TokenStoragePath)
        self.contractFusdVault = signer.borrow<&OrderBookFusd.Vault>(from: OrderBookFusd.TokenStoragePath)
    }

    execute {
        OrderBookV7.limitOrder(self.maker, price: UFix64(${(price)}), amount: UFix64(${(amount)}), isBid: ${(isBid)})

        if isBid {
            let tokenVault <- self.userFlowVaultRef.withdraw(amount: UFix64(${(amount)}) as! @FungibleToken.Vault
            self.contractFlowVault.deposit(from: <- tokenVault)
        }
        else {
            let tokenVault <- self.userFusdVaultRef.withdraw(amount: UFix64(${(amount)}) as! @FungibleToken.Vault
            self.contractFusdVault.deposit(from: <- tokenVault)
        }
    }
}
`