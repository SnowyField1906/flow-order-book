pub contract SimpleMarket {
    
    pub let MarketStoragePath: StoragePath
    pub let MarketPublicPath: PublicPath
    pub let UserStoragePath: StoragePath
    pub let UserPublicPath: PublicPath


    pub resource Offer {

        pub      let payToken:  String
        pub(set) var payAmount: UFix64
        pub      let buyToken:  String
        pub(set) var buyAmount: UFix64

        init(_ payToken: String, _ payAmount: UFix64, _ buyToken: String, _ buyAmount: UFix64) {
            self.payToken  = payToken
            self.payAmount = payAmount
            self.buyToken  = buyToken
            self.buyAmount = buyAmount
        }
    }


    pub resource User {
        pub resource balance: UFix64

        pub resource ownedTake: [UFix64]
        pub resource ownedMake: [UFix64]

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


    pub fun createUser(): @User {
        return <- create User()
    }


    pub resource Market {

        pub var offers: @{UFix64: Offer}
        pub var users: @{Address: User}

        init () {
            self.offers <- {}
            self.users <- {}
        }

        pub fun makeOffer(_ payToken: String, _ payAmount: UFix64, _ buyToken: String, _ buyAmount: UFix64): UFix64 {
            let id = getCurrentBlock().timestamp
            var newOffer: @Offer <- create Offer(payToken, payAmount, buyToken, buyAmount)
            self.offers[id] <-! newOffer

            return id
        }

        // pub fun takeOffer(_ id: UFix64, _ amount: UFix64) {
        //     let offer = self.offers[id]!
        //     let user = self.users[getAccount().address]!

        //     if user.balance < amount {
        //         panic("Not enough balance")
        //     }

        //     if offer.payAmount < amount {
        //         panic("Not enough amount")
        //     }

        //     user.taken(id, amount)
        //     offer.payAmount = offer.payAmount - amount
        //     offer.buyAmount = offer.buyAmount - amount

        //     if offer.payAmount == 0.0 {
        //         destroy self.offers[id]
        //     }
        // }

        destroy() {
            destroy self.offers
            destroy self.users
        }
    }


    
    init() {
        self.MarketStoragePath = /storage/market
        self.MarketPublicPath = /public/market
        self.UserStoragePath = /storage/user
        self.UserPublicPath = /public/user

        self.account.save(<-create Market(), to: self.MarketStoragePath)
        self.account.link<&Market>(self.MarketPublicPath, target: self.MarketStoragePath)

        self.account.save(<-create User(), to: self.UserStoragePath)
        self.account.link<&User>(self.UserPublicPath, target: self.UserStoragePath)
    }
}
 