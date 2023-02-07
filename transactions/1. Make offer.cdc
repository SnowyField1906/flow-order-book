import SimpleMarket from "./../contracts/SimpleMarket.cdc"

transaction(payToken: Address, payAmount: UFix64, buyToken: Address, buyAmount: UFix64) {

    let maker: Address

    prepare(acct: AuthAccount) {
        self.maker = acct.address
    }

    execute {
        let offer = SimpleMarket.makeOffer(self.maker, payAmount, buyAmount)    
    }
}
 