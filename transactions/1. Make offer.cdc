import SimpleMarket from 0x01

transaction(payToken: Address, payAmount: UFix64, buyToken: Address, buyAmount: UFix64) {

    // let userRef: &SimpleMarket.User
    // let maker: Address

    prepare(acct: AuthAccount) {
    
        // self.userRef = acct.borrow<&SimpleMarket.User>(from: /storage/User)
        // ?? panic("Could not borrow user reference")

        // self.maker = acct.address

    }

    execute {
        let offer = SimpleMarket.makeOffer(self.maker, payToken, payAmount, buyToken, buyAmount)!

        self.userRef.made(getCurrentBlock().timestamp)
        
    }
}