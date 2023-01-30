import SimpleMarket from 0x01
import Token0 from 0x02
import Token1 from 0x03

transaction(_ payToken: String, _ payAmount: UFix64, _ buyToken: String, _ buyAmount: UFix64) {

    let userRef: &SimpleMarket.User

    prepare(acct: AuthAccount) {
    
        self.userRef = acct.borrow<&SimpleMarket.User>(from: /storage/User)
        ?? panic("Could not borrow user reference")

    }

    execute {
        let offerID = SimpleMarket.makeOffer(payToken, payAmount, buyToken, buyAmount)
        self.userRef.made(offerID)
    }
}