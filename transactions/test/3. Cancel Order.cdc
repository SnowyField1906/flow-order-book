import OrderBookV13 from 0xOrderBookV13
import FlowFusdVaultV2 from 0xFlowFusdVaultV2
import FungibleToken from 0xFungibleToken

transaction(price: UFix64, isBid: Bool) {
    let maker: Address

    prepare(signer: AuthAccount) {
        self.maker = signer.address

        let receiveAmount = OrderBookV13.cancelOrder(price: price, isBid: isBid)

        if isBid {
            let userFlowVault = getAccount(self.maker).getCapability(/public/flowTokenReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
            let contractFlowVault <- FlowFusdVaultV2.withdrawFlow(amount: receiveAmount, owner: self.maker)
            userFlowVault.deposit(from: <-contractFlowVault)
        }
        else {
            let userFusdVault = getAccount(self.maker).getCapability(/public/fusdReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
            let contractFusdVault <- FlowFusdVaultV2.withdrawFusd(amount: receiveAmount, owner: self.maker)
            userFusdVault.deposit(from: <-contractFusdVault)
        }
    }

    execute {
    }
}