import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

transaction(id: UInt32, quantity: UFix64) {

    let maker: Address

    prepare(acct: AuthAccount) {
        self.maker = acct.address
    }

    execute {
        let offer = OrderBookV6.marketOrder(id, quantity)    
    }
}
 