import OrderBookV7 from "./../contracts/OrderBookV7.cdc"

transaction(payAmount: UFix64, buyAmount: UFix64, isBid: Bool) {

    let maker: Address

    prepare(acct: AuthAccount) {
        self.maker = acct.address
    }

    execute {
        OrderBookV7.limitOrder(self.maker, payAmount: payAmount, buyAmount: buyAmount, isBid: isBid)    
    }
}
 