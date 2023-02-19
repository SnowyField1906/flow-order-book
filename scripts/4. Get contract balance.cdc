import OrderBookVaultV12 from 0xOrderBookVaultV12
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main() : {String: UFix64} {
    return {"Flow": OrderBookVaultV12.flowVault.balance, "FUSD": OrderBookVaultV12.fusdVault.balance}
}