import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

transaction(payAmount: UFix64, buyAmount: UFix64, isBid: Bool) {

    let maker: Address

    prepare(acct: AuthAccount) {
        self.maker = acct.address
    }

    execute {
        OrderBookV6.limitOrder(self.maker, payAmount: payAmount, buyAmount: buyAmount, isBid: isBid)    
    }
}
 