import OrderBookV11 from 0xOrderBookV11
import OrderBookVaultV10 from 0xOrderBookVaultV10
import FungitibleToken from 0xFungibleToken

transaction(price: UFix64, isBid: Bool) {
    let maker: Address

    prepare(signer: AuthAccount) {
        self.maker = signer.address

        let receiveAmount = OrderBookV11.cancelOrder(price: price, isBid: isBid)

        let contractVault = signer.borrow<&OrderBookVaultV10.TokenBundle>(from: OrderBookVaultV10.TokenStoragePath)!
        if isBid {
            let userFlowVault = getAccount(self.maker).getCapability(/public/flowTokenReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
            let contractFlowVault <- contractVault.withdrawFlow(amount: receiveAmount, admin: self.maker)
            userFlowVault.deposit(from: <-contractFlowVault)
        }
        else {
            let userFusdVault = getAccount(self.maker).getCapability(/public/fusdReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
            let contractFusdVault <- contractVault.withdrawFusd(amount: receiveAmount, admin: self.maker)
            userFusdVault.deposit(from: <-contractFusdVault)
        }
    }

    execute {
    }
}