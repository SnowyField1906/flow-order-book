import Token0 from 0x02
import Token1 from 0x03

pub contract SimpleMarket {

    pub var offers: @{UFix64: Offer}
    pub var users: @{Address: User}

    init() {
        self.offers <- {}
        self.users <- {}
    }


    pub resource Offer {

        pub      let payToken  : Address
        pub(set) var payAmount : UFix64
        pub      let buyToken  : Address
        pub(set) var buyAmount : UFix64
        pub      let maker     : Address

        init(_ maker: Address, _ payToken: Address, _ payAmount: UFix64, _ buyToken: Address, _ buyAmount: UFix64) {
            self.payToken   = payToken
            self.payAmount  = payAmount
            self.buyToken   = buyToken
            self.buyAmount  = buyAmount
            self.maker      = maker
        }
    }

    pub resource interface HasOwnedOffer {
        pub var balance0: UFix64
        pub var balance1: UFix64

        pub var ownedTake: [UFix64]
        pub var ownedMake: [UFix64]

        pub fun taken(_ id: UFix64)
        pub fun made(_ id: UFix64)
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

        pub fun taken(_ id: UFix64) {
            self.ownedTake.append(id)
        }

        pub fun made(_ id: UFix64) {
            self.ownedMake.append(id)
        }
    }

    pub fun makeOffer(_ maker: Address, _ payToken: Address, _ payAmount: UFix64, _ buyToken: Address, _ buyAmount: UFix64): &Offer? {
        let id = getCurrentBlock().timestamp
        var newOffer: @Offer <- create Offer(maker, payToken, payAmount, buyToken, buyAmount)
        self.offers[id] <-! newOffer

        return &self.offers[id] as &Offer? 
    }

    pub fun createUser(): @User {
        return <- create User()
    }
}