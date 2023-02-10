import * as fcl from "@onflow/fcl";

export default async function makeOffer(payAmount, buyAmount, isBid) {
    return fcl.mutate({
        cadence: OFFER_DETAILS(payAmount, buyAmount, isBid),
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        authorizations: [fcl.currentUser],
    });
}

const OFFER_DETAILS = (payAmount, buyAmount, isBid) => `
import OrderBookV2 from 0xOrderBookV2

transaction() {

    let maker: Address

    prepare(acct: AuthAccount) {
        self.maker = acct.address
    }

    execute {
        OrderBookV2.makeOffer(self.maker, payAmount: UFix64(${(payAmount)}), buyAmount: UFix64(${(buyAmount)}), isBid: ${(isBid)})    
    }
}
`