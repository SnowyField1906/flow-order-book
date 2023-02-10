import OrderBookV2 from "./../contracts/OrderBookV2.cdc"

transaction(id: UInt32, quantity: UFix64) {

    let maker: Address

    prepare(acct: AuthAccount) {
        self.maker = acct.address
    }

    execute {
        let offer = OrderBookV2.buy(id, quantity)    
    }
}
 