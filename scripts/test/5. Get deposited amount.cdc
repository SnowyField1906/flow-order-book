import FlowFusdVaultV2 from 0xFlowFusdVaultV2
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main(userAddress: Address) : {String: UFix64} {
    return {"Flow": FlowFusdVaultV2.vaults[userAddress]?.flowBalance ?? 0.0, "FUSD": FlowFusdVaultV2.vaults[userAddress]?.fusdBalance ?? 0.0}
}