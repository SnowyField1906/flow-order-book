import Token1 from 0x04
import Token2 from 0x05

pub contract SimpleMarket {

    pub var offers: @{UFix64: Offer}
    pub var users: @{Address: User}

    init() {
        self.offers <- {}
        self.users <- {}
    }


    pub resource Offer {

        pub      let payToken : Address
        pub(set) var payAmount: UFix64
        pub      let buyToken : Address
        pub(set) var buyAmount: UFix64

        init(_ payTokenID: Address, _ payAmount: UFix64, _ buyTokenID: Address, _ buyAmount: UFix64) {
            self.payToken  = payTokenID
            self.payAmount = payAmount
            self.buyToken  = buyTokenID
            self.buyAmount = buyAmount
        }
    }

    pub resource interface HasOwnedOffer {
        pub var balance0: UFix64
        pub var balance1: UFix64

        pub var ownedTake: [UFix64]
        pub var ownedMake: [UFix64]

        pub fun taken(_ id: UFix64, _ offer: &Offer)
        pub fun made(_ id: UFix64, _ offer: &Offer)
    }


    pub resource User: HasOwnedOffer {
        pub var balance0: UFix64
        pub var balance1: UFix64

        pub var ownedTake: [UFix64]
        pub var ownedMake: [UFix64]

        init() {
            self.balance0 = 100.0
            self.balance1 = 100.0

            self.ownedTake = []
            self.ownedMake = []
        }

        pub fun taken(_ id: UFix64, _ offer: &Offer) {
            self.ownedTake.append(id)
            self.balance0 = self.balance0 + offer.buyAmount
        }

        pub fun made(_ id: UFix64, _ offer: &Offer) {
            self.ownedMake.append(id)
        }
    }

    pub fun makeOffer(_ payTokenID: Address, _ payAmount: UFix64, _ buyTokenID: Address, _ buyAmount: UFix64): &Offer? {
        let id = getCurrentBlock().timestamp
        var newOffer: @Offer <- create Offer(payTokenID, payAmount, buyTokenID, buyAmount)
        self.offers[id] <-! newOffer

        return &self.offers[id] as &Offer? 
    }

    pub fun createUser(): @User {
        return <- create User()
    }
    
}