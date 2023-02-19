import OrderBookV13 from 0xOrderBookV13
import OrderBookVaultV12 from 0xOrderBookVaultV12
import FungibleToken from 0xFungibleToken

transaction(price: UFix64, isBid: Bool) {
    let maker: Address

    prepare(signer: AuthAccount) {
        self.maker = signer.address

        let receiveAmount = OrderBookV13.cancelOrder(price: price, isBid: isBid)

        let contractVault = signer.borrow<&OrderBookVaultV12.Administrator>(from: OrderBookVaultV12.TokenStoragePath)!

        if isBid {
            let userFlowVault = getAccount(self.maker).getCapability(/public/flowTokenReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
            let contractFlowVault <- contractVault.withdrawFlow(amount: receiveAmount)
            userFlowVault.deposit(from: <-contractFlowVault)
        }
        else {
            let userFusdVault = getAccount(self.maker).getCapability(/public/fusdReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
            let contractFusdVault <- contractVault.withdrawFusd(amount: receiveAmount)
            userFusdVault.deposit(from: <-contractFusdVault)
        }
    }

    execute {
    }
}