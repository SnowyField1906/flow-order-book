import OrderBook from "./../contracts/OrderBook.cdc"

transaction(payAmount: UFix64, buyAmount: UFix64) {

    let maker: Address

    prepare(acct: AuthAccount) {
        self.maker = acct.address
    }

    execute {
        OrderBook.makeOffer(self.maker, payAmount: payAmount, buyAmount: buyAmount)    
    }
}
 