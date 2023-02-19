import OrderBookVaultV12 from 0xOrderBookVaultV12
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main(userAddress: Address): Bool {
    let signer = getAccount(userAddress)

    let vaultRef = signer.getCapability(OrderBookVaultV12.TokenPublicPath)!
        .borrow<&OrderBookVaultV12.Administrator>(from: OrderBookVaultV12.TokenStoragePath)
        ?? nil

    let receiverRef = signer.getCapability(/public/fusdReceiver)!
    .borrow<&FUSD.Vault{FungibleToken.Receiver}>()
        ?? nil

    let balanceRef = signer.getCapability(/public/fusdBalance)!
        .borrow<&FUSD.Vault{FungibleToken.Balance}>()
        ?? nil

    return (receiverRef != nil) && (balanceRef != nil) && (vaultRef != nil)
}