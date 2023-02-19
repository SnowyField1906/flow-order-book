import FungibleToken from 0x9a0766d93b6608b7
import FUSD from 0xe223d8a629e49c68
import FlowToken from 0x7e60df042a9c0868

pub contract OrderBookVaultV10 {
  pub let TokenStoragePath  : StoragePath
  pub let TokenPublicPath  : PublicPath

  pub resource interface TokenBundlePublic {
    pub let admins: [Address]
    pub fun depositFlow(flowVault: @FungibleToken.Vault, admin: Address)
    pub fun depositFusd(fusdVault: @FungibleToken.Vault, admin: Address)
    pub fun withdrawFlow(amount: UFix64, admin: Address): @FungibleToken.Vault
    pub fun withdrawFusd(amount: UFix64, admin: Address): @FungibleToken.Vault
    pub fun getFlowBalance(): UFix64
    pub fun getFusdBalance(): UFix64
  }

  pub resource TokenBundle: TokenBundlePublic {
    pub let admins: [Address]
    pub let flowVault: @FlowToken.Vault
    pub let fusdVault: @FUSD.Vault
    
    init(admins: [Address]) {
      self.admins = admins
      self.flowVault <- FlowToken.createEmptyVault() as! @FlowToken.Vault
      self.fusdVault <- FUSD.createEmptyVault()
    }

    pub fun depositFlow(flowVault: @FungibleToken.Vault, admin: Address) {
      self.flowVault.deposit(from: <-flowVault)
      if self.admins.contains(admin) == false {
        self.admins.append(admin)
      }
    }

    pub fun depositFusd(fusdVault: @FungibleToken.Vault, admin: Address) {
      self.fusdVault.deposit(from: <-fusdVault)
      if self.admins.contains(admin) == false {
        self.admins.append(admin)
      }
    }

    pub fun withdrawFlow(amount: UFix64, admin: Address): @FungibleToken.Vault {
      return <- self.flowVault.withdraw(amount: amount)
    }

    pub fun withdrawFusd(amount: UFix64, admin: Address): @FungibleToken.Vault {
      return <- self.fusdVault.withdraw(amount: amount)
    }

    pub fun getFlowBalance(): UFix64 {
      return self.flowVault.balance
    }

    pub fun getFusdBalance(): UFix64 {
      return self.fusdVault.balance
    }

    destroy () {
      destroy self.flowVault
      destroy self.fusdVault
    }
  }

  pub fun createTokenBundle(admins: [Address]): @TokenBundle {
    return <-create TokenBundle(admins: admins)
  }

  init() {

    self.TokenPublicPath = /public/OrderBookVaultTokenV10
    self.TokenStoragePath = /storage/OrderBookVaultTokenV10

    self.account.save(<-create TokenBundle(admins: []), to: self.TokenStoragePath)
    self.account.link<&TokenBundle{TokenBundlePublic}>(self.TokenPublicPath, target: self.TokenStoragePath)
  }
}