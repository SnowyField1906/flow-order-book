import * as fcl from "@onflow/fcl";

export default async function limitOrder(price, amount, isBid) {
    return fcl.mutate({
        cadence: OFFER_DETAILS(price, amount, isBid),
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        authorizations: [fcl.currentUser],
    });
}

const OFFER_DETAILS = (price, amount, isBid) => `
import OrderBookV6 from 0xOrderBookV6

transaction() {

    let maker: Address

    prepare(acct: AuthAccount) {
        self.maker = acct.address
    }

    execute {
        OrderBookV6.limitOrder(self.maker, price: UFix64(${(price)}), amount: UFix64(${(amount)}), isBid: ${(isBid)})    
    }
}
`