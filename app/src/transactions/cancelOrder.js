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
import OrderBookV7 from 0xOrderBookV7
import OrderBookVault from 0xOrderBookVault
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction(amount: UFix64, isBid: Bool) {
    let maker: Address

    prepare(signer: AuthAccount) {
        self.maker = signer.address

        if signer.borrow<&OrderBookVaultV3.TokenBundle>(from: OrderBookVaultV3.TokenStoragePath) == nil {
            signer.save(<- OrderBookVaultV3.createTokenBundle(admins: [signer.address]), to: OrderBookVaultV3.TokenStoragePath)
            signer.link<&OrderBookVaultV3.TokenBundle{OrderBookVaultV3.TokenBundlePublic}>(OrderBookVaultV3.TokenPublicPath, target: OrderBookVaultV3.TokenStoragePath)
       }

        let contractVault = signer.borrow<&OrderBookVaultV3.TokenBundle>(from: OrderBookVaultV3.TokenStoragePath)!

        let receiveAmount = OrderBookV7.cancelOrder(price: price, isBid: isBid)
        contractVault.withdrawFlow(amount: receiveAmount, admin: self.maker)
    }

    execute {
        
    }
}
`