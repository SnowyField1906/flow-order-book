import OrderBookVaultV11 from 0xOrderBookVaultV11
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main() : {String: UFix64} {
    return {"Flow": OrderBookVaultV11.flowVault.balance, "FUSD": OrderBookVaultV11.fusdVault.balance}
}