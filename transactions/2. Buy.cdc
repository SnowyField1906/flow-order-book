import OrderBookV7 from "./../contracts/OrderBookV7.cdc"

transaction(id: UInt32, quantity: UFix64) {

    let maker: Address

    prepare(acct: AuthAccount) {
        self.maker = acct.address
    }

    execute {
        let offer = OrderBookV7.marketOrder(id, quantity)    
    }
}
 