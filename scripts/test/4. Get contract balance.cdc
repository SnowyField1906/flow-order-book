import FlowFusdVaultV2 from 0xFlowFusdVaultV2
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main() : {String: UFix64} {
    return {"Flow": FlowFusdVaultV2.getFlowBalance(), "FUSD": FlowFusdVaultV2.getFusdBalance()}
}