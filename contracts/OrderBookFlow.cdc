import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868


pub contract OrderBookFlow: FungibleToken {
  pub let TokenStoragePath        : StoragePath
  pub let TokenPublicBalancePath  : PublicPath
  pub let TokenPublicReceiverPath : PublicPath

  pub var totalSupply: UFix64

  access(contract) let vault: @FlowToken.Vault

  pub resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance {
    pub var balance: UFix64

    init(balance: UFix64) {
      self.balance = balance
    }

    pub fun deposit(from: @FungibleToken.Vault) {
      let vault <- from as! @FlowToken.Vault

      self.balance = self.balance + vault.balance

      destroy vault
    }

    pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
      self.balance = self.balance - amount

      return <- create Vault(balance: amount)
    }
  }

  pub fun createEmptyVault(): @FungibleToken.Vault {
    return <-create Vault(balance: 0.0)
  }

  pub fun getBalance(): UFix64 {
    return self.vault.balance
  }


  pub event TokensInitialized(initialSupply: UFix64)
  pub event TokensWithdrawn(amount: UFix64, from: Address?)
  pub event TokensDeposited(amount: UFix64, to: Address?)
  
  init() {
    self.TokenStoragePath        = /storage/orderBookFlow
    self.TokenPublicBalancePath  = /public/orderBookFlowBalance
    self.TokenPublicReceiverPath = /public/orderBookFlowReceiver

    self.totalSupply = 0.0

    self.vault <- FlowToken.createEmptyVault() as! @FlowToken.Vault
  }
}