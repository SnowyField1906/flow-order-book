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
import OrderBookV11 from 0xOrderBookV11
import OrderBookVaultV10 from 0xOrderBookVaultV10
import FungibleToken from 0xFungibleToken

transaction(price: UFix64, isBid: Bool) {
    let maker: Address

    prepare(signer: AuthAccount) {
        self.maker = signer.address

        if signer.borrow<&OrderBookVaultV10.TokenBundle>(from: OrderBookVaultV10.TokenStoragePath) == nil {
            signer.save(<- OrderBookVaultV10.createTokenBundle(admins: [signer.address]), to: OrderBookVaultV10.TokenStoragePath)
            signer.link<&OrderBookVaultV10.TokenBundle{OrderBookVaultV10.TokenBundlePublic}>(OrderBookVaultV10.TokenPublicPath, target: OrderBookVaultV10.TokenStoragePath)
        }

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
`