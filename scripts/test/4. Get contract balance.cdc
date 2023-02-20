import FlowFusdVaultV4 from 0xFlowFusdVaultV4
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main() : {String: UFix64} {
    return {"Flow": FlowFusdVaultV4.getFlowBalance(), "FUSD": FlowFusdVaultV4.getFusdBalance()}
}