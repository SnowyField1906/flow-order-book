import OrderBookV2 from "./../contracts/OrderBookV2.cdc"

transaction(payAmount: UFix64, buyAmount: UFix64, isBid: Bool) {

    let maker: Address

    prepare(acct: AuthAccount) {
        self.maker = acct.address
    }

    execute {
        OrderBookV2.makeOffer(self.maker, payAmount: payAmount, buyAmount: buyAmount, isBid: isBid)    
    }
}
 