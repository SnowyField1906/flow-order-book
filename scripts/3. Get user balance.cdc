import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main() : {String: UFix64} {
    let user = getAccount(${address})

    let FlowRef = user.getCapability(/public/flowTokenBalance)
                    .borrow<&FlowToken.Vault{FungibleToken.Balance}>()
                    ?? panic("Could not borrow a reference to the receiver")
    let FUSDRef = user.getCapability(/public/fusdBalance)
                    .borrow<&FUSD.Vault{FungibleToken.Balance}>()
                    ?? panic("Could not borrow a reference to the receiver")

    return {"Flow": FlowRef.balance, "FUSD": FUSDRef.balance}
}