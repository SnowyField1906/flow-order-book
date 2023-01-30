import SimpleMarket from 0x01
import Token0 from 0x02
import Token1 from 0x03

transaction(payToken: Address, payAmount: UFix64, buyToken: Address, buyAmount: UFix64) {

    let userRef: &SimpleMarket.User
    let maker: Address

    prepare(acct: AuthAccount) {
    
        self.userRef = acct.borrow<&SimpleMarket.User>(from: /storage/User)
        ?? panic("Could not borrow user reference")

        self.maker = acct.address

    }

    execute {
        let offer = SimpleMarket.makeOffer(self.maker, payToken, payAmount, buyToken, buyAmount)!

        self.userRef.made(getCurrentBlock().timestamp)
        
    }
}