import * as fcl from "@onflow/fcl";

export default async function cancelOrder(price, isBid) {
    return fcl.mutate({
        cadence: CANCEL_ORDER,
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        authorizations: [fcl.currentUser],
        args: (arg, t) => [
            arg(price.toString(), t.UFix64),
            arg(isBid, t.Bool),
        ],
    });
}

const CANCEL_ORDER = `
import OrderBookV10 from 0xOrderBookV10
import OrderBookVaultV9 from 0xOrderBookVaultV9
import FungibleToken from 0xFungibleToken

transaction(price: UFix64, isBid: Bool) {
    let maker: Address

    prepare(signer: AuthAccount) {
        self.maker = signer.address

        if signer.borrow<&OrderBookVaultV9.TokenBundle>(from: OrderBookVaultV9.TokenStoragePath) == nil {
            signer.save(<- OrderBookVaultV9.createTokenBundle(admins: [signer.address]), to: OrderBookVaultV9.TokenStoragePath)
            signer.link<&OrderBookVaultV9.TokenBundle{OrderBookVaultV9.TokenBundlePublic}>(OrderBookVaultV9.TokenPublicPath, target: OrderBookVaultV9.TokenStoragePath)
        }

        let receiveAmount = OrderBookV10.cancelOrder(price: price, isBid: isBid)

        let contractVault = signer.borrow<&OrderBookVaultV9.TokenBundle>(from: OrderBookVaultV9.TokenStoragePath)!
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
`