import OrderBookVaultV10 from 0xOrderBookVaultV10
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main() : {String: UFix64} {
    let tokenBundle = getAccount(0xOrderBookVaultV10).getCapability(OrderBookVaultV10.TokenPublicPath).borrow<&OrderBookVaultV10.TokenBundle{OrderBookVaultV10.TokenBundlePublic}>()!

    return {"Flow": tokenBundle.getFlowBalance(), "FUSD": tokenBundle.getFusdBalance()}
}