import OrderBookVaultV12 from 0xOrderBookVaultV12
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main(userAddress: Address) : {String: UFix64} {
    let tokenBundle = getAccount(userAddress).getCapability(OrderBookVaultV12.TokenPublicPath).borrow<&OrderBookVaultV12.Administrator>()!

    return {"Flow": tokenBundle.getFlowBalance(), "FUSD": tokenBundle.getFusdBalance()}
}