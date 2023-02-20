import FlowFusdVaultV4 from 0xFlowFusdVaultV4
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main(userAddress: Address) : {String: UFix64} {
    return {"Flow": FlowFusdVaultV4.vaults[userAddress]?.flowBalance ?? 0.0, "FUSD": FlowFusdVaultV4.vaults[userAddress]?.fusdBalance ?? 0.0}
}