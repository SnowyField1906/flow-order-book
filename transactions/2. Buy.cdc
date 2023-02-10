import OrderBook from "./../contracts/OrderBook.cdc"

transaction(id: UInt32, quantity: UFix64) {

    let maker: Address

    prepare(acct: AuthAccount) {
        self.maker = acct.address
    }

    execute {
        let offer = OrderBook.buy(id, quantity)    
    }
}
 