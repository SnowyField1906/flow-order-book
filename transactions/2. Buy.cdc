import SimpleMarket from "./../contracts/SimpleMarket.cdc"

transaction(id: UInt32, quantity: UFix64) {

    let maker: Address

    prepare(acct: AuthAccount) {
        self.maker = acct.address
    }

    execute {
        let offer = SimpleMarket.buy(id, quantity)    
    }
}
 