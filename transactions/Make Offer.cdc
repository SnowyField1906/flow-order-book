import SimpleMarket from 0x1

transaction(_ payToken: String, _ payAmount: UFix64, _ buyToken: String, _ buyAmount: UFix64) {

    let userRef: &SimpleMarket.User

    let marketRef: &SimpleMarket.Market

    prepare(signer: AuthAccount) {
            
            self.userRef = signer.borrow<&SimpleMarket.User>(from: /storage/user)
    
                ?? panic("Could not borrow reference to the Users collection")
    
            self.marketRef = signer.borrow<&SimpleMarket.Market>(from: /storage/market)
    
                ?? panic("Could not borrow reference to the Market collection")
    
        }

    execute {
        let offerID = self.marketRef.makeOffer(payToken, payAmount, buyToken, buyAmount)
        self.userRef.made(offerID)
    }
}