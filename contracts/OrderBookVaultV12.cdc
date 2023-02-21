import FungibleToken from 0x9a0766d93b6608b7
import FUSD from 0xe223d8a629e49c68
import FlowToken from 0x7e60df042a9c0868

pub contract OrderBookVaultV13 {
  pub let TokenStoragePath  : StoragePath
  pub let TokenPublicPath  : PublicPath

  access(contract) let flowVault: @FlowToken.Vault
  access(contract) let fusdVault: @FUSD.Vault

  pub resource Administrator {
    pub var flowBalance: UFix64
    pub var fusdBalance: UFix64

    pub fun depositFlow(from: @FlowToken.Vault) {
      self.flowBalance = self.flowBalance + from.balance
      OrderBookVaultV13.flowVault.deposit(from: <- (from as! @FungibleToken.Vault))
    }

    pub fun depositFusd(from: @FUSD.Vault) {
      self.fusdBalance = self.fusdBalance + from.balance
      OrderBookVaultV13.fusdVault.deposit(from: <- (from as! @FungibleToken.Vault))
    }

    pub fun withdrawFlow(amount: UFix64): @FungibleToken.Vault {
      self.flowBalance = self.flowBalance - amount
      return <- OrderBookVaultV13.flowVault.withdraw(amount: amount)
    }

    pub fun withdrawFusd(amount: UFix64): @FungibleToken.Vault {
      self.fusdBalance = self.fusdBalance - amount
      return <- OrderBookVaultV13.fusdVault.withdraw(amount: amount)
    }

    init() {
      self.flowBalance = 0.0
      self.fusdBalance = 0.0
    }
  }

  pub fun createAdministrator(): @Administrator {
    return <-create Administrator()
  }

  init() {
    self.flowVault <- FlowToken.createEmptyVault() as! @FlowToken.Vault
    self.fusdVault <- FUSD.createEmptyVault()

    self.TokenStoragePath = /storage/OrderBookVaultV13
    self.TokenPublicPath = /public/OrderBookVaultV13

    self.account.save(<-self.createAdministrator(), to: self.TokenStoragePath)
    self.account.link<&Administrator>(self.TokenPublicPath, target: self.TokenStoragePath)
  }
}
 