import FungibleToken from 0x9a0766d93b6608b7
import FUSD from 0xe223d8a629e49c68
import FlowToken from 0x7e60df042a9c0868

pub contract FlowFusdVaultV4 {
    access(contract) let flowVault: @FlowToken.Vault
    access(contract) let fusdVault: @FUSD.Vault

    pub let vaults: {Address: Balance}
        
    pub struct Balance {
        pub let flowBalance: UFix64
        pub let fusdBalance: UFix64

        init(flowBalance: UFix64, fusdBalance: UFix64) {
            self.flowBalance = flowBalance
            self.fusdBalance = fusdBalance
        }
    }

    pub fun depositFlow(from: @FlowToken.Vault, owner: Address) {
        self.vaults[owner] = Balance(
            flowBalance: (self.vaults[owner]?.flowBalance ?? 0.0) + from.balance,
            fusdBalance: (self.vaults[owner]?.fusdBalance ?? 0.0)
        )
        FlowFusdVaultV4.flowVault.deposit(from: <- (from as! @FungibleToken.Vault))
    }

    pub fun depositFusd(from: @FUSD.Vault, owner: Address) {
        self.vaults[owner] = Balance(
            flowBalance: (self.vaults[owner]?.flowBalance ?? 0.0),
            fusdBalance: (self.vaults[owner]?.fusdBalance ?? 0.0) + from.balance
        )
        FlowFusdVaultV4.fusdVault.deposit(from: <- (from as! @FungibleToken.Vault))
    }

    pub fun withdrawFlow(amount: UFix64, owner: Address): @FungibleToken.Vault {
        self.vaults[owner] = Balance(
            flowBalance: (self.vaults[owner]?.flowBalance ?? 0.0) - amount,
            fusdBalance: (self.vaults[owner]?.fusdBalance ?? 0.0)
        )
        return <- FlowFusdVaultV4.flowVault.withdraw(amount: amount)
    }

    pub fun withdrawFusd(amount: UFix64, owner: Address): @FungibleToken.Vault {
        self.vaults[owner] = Balance(
            flowBalance: (self.vaults[owner]?.flowBalance ?? 0.0),
            fusdBalance: (self.vaults[owner]?.fusdBalance ?? 0.0) - amount
        )
        return <- FlowFusdVaultV4.fusdVault.withdraw(amount: amount)
    }

    pub fun getFlowBalance(): UFix64 {
        return self.flowVault.balance
    }

    pub fun getFusdBalance(): UFix64 {
        return self.fusdVault.balance
    }

    init() {
        self.flowVault <- FlowToken.createEmptyVault() as! @FlowToken.Vault
        self.fusdVault <- FUSD.createEmptyVault() as! @FUSD.Vault

        self.vaults = {}
    }
}
 