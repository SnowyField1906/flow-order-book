pub contract SimpleMarket {

    pub var offers: @{UFix64: Offer}
    pub var users: @{Address: User}

    pub resource Offer {

        pub      let payToken : String
        pub(set) var payAmount: UFix64
        pub      let buyToken : String
        pub(set) var buyAmount: UFix64

        init(_ payToken: String, _ payAmount: UFix64, _ buyToken: String, _ buyAmount: UFix64) {
            self.payToken  = payToken
            self.payAmount = payAmount
            self.buyToken  = buyToken
            self.buyAmount = buyAmount
        }
    }

    pub resource interface HasOwnedOffer {
        pub var balance: UFix64

        pub var ownedTake: [UFix64]
        pub var ownedMake: [UFix64]

        pub fun taken(_ id: UFix64)
        pub fun made(_ id: UFix64)
        pub fun increaseBalance(_ amount: UFix64)
        pub fun decreaseBalance(_ amount: UFix64)
        pub fun getMade(): [UFix64]
    }


    pub resource User: HasOwnedOffer {
        pub var balance: UFix64

        pub var ownedTake: [UFix64]
        pub var ownedMake: [UFix64]

        init() {
            self.balance = 100.0

            self.ownedTake = []
            self.ownedMake = []
        }

        pub fun taken(_ id: UFix64) {
            self.ownedTake.append(id)
        }

        pub fun made(_ id: UFix64) {
            self.ownedMake.append(id)
        }

        pub fun increaseBalance(_ amount: UFix64) {
            self.balance = self.balance + amount
        }

        pub fun decreaseBalance(_ amount: UFix64) {
            self.balance = self.balance - amount
        }

        pub fun getMade(): [UFix64] {
            return self.ownedMake
        }

        pub fun getTaken(): [UFix64] {
            return self.ownedTake
        }
    }

    pub fun makeOffer(_ payToken: String, _ payAmount: UFix64, _ buyToken: String, _ buyAmount: UFix64): UFix64 {
        let id = getCurrentBlock().timestamp
        var newOffer: @Offer <- create Offer(payToken, payAmount, buyToken, buyAmount)
        self.offers[id] <-! newOffer

        return id
    }

    pub fun createUser(): @User {
        return <- create User()
    }

    init() {
        self.offers <- {}
        self.users <- {}

    }
}
 