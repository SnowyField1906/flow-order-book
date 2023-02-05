export const contractNames = ["SimpleMarket"]

export const scriptNames = [
    "0. Load all offers",
    "1. Load all offer ids",
    "2. Load all offer prices",
    "3. Load offer detail",
    "4. Load user balance",
    "5. Load id detail",
    "6. Load adjacent ids",
    "7. Load current id"
]

export const transactionNames = [
    "0. Setup account",
    "1. Make offer",
    "2. Buy",
]

export const addressMap = { Profile: "0xf8d6e0586b0a20c7" }

export const transactionTemplates = [
    ``,
    `import SimpleMarket from "./../contracts/SimpleMarket.cdc"

    transaction(payToken: Address, payAmount: UFix64, buyToken: Address, buyAmount: UFix64) {
    
        let maker: Address
    
        prepare(acct: AuthAccount) {
            self.maker = acct.address
        }
    
        execute {
            let offer = SimpleMarket.makeOffer(self.maker, payToken, payAmount, buyToken, buyAmount)    
        }
    }`,
    `import SimpleMarket from "./../contracts/SimpleMarket.cdc"

    transaction(id: UInt32, quantity: UFix64) {
    
        let maker: Address
    
        prepare(acct: AuthAccount) {
            self.maker = acct.address
        }
    
        execute {
            let offer = SimpleMarket.buy(id, quantity)    
        }
    }`
]

export const scriptTemplates = [
    `import SimpleMarket from "./../contracts/SimpleMarket.cdc"

    pub fun main(): &{UInt32: SimpleMarket.Offer}? {
        return &SimpleMarket.offers as &{UInt32: SimpleMarket.Offer}?
    }`,
    `import SimpleMarket from "./../contracts/SimpleMarket.cdc"

    pub fun main(): [UInt32] {
        let ids: [UInt32] = []
    
        var current = SimpleMarket.current
        while (current != 0) {
            ids.append(current)
            current = SimpleMarket.ids[current]!.right
        }
    
        return ids
    }`,
    `import SimpleMarket from "./../contracts/SimpleMarket.cdc"

    pub fun main(): [UFix64] {
        let ids: [UFix64] = []
    
        var current = SimpleMarket.current
        while (current != 0) {
            ids.append(SimpleMarket.getPrice(current))
            current = SimpleMarket.ids[current]!.right
        }
    
        return ids
    }`,
    `import SimpleMarket from "./../contracts/SimpleMarket.cdc"

    pub fun main(id: UInt32): &SimpleMarket.Offer? {
        return &SimpleMarket.offers[id] as &SimpleMarket.Offer?
    }`,
    `import Token0 from 0xf8d6e0586b0a20c7
    import Token1 from 0xf8d6e0586b0a20c7
    
    pub fun main(user: Address) : [UFix64] {
        let user = getAccount(user)
    
        let userRef0 = user.getCapability(/public/Receiver0)
                        .borrow<&Token0.Vault{Token0.Balance}>()
                        ?? panic("Could not borrow a reference to the receiver")
        let userRef1 = user.getCapability(/public/Receiver1)
                        .borrow<&Token1.Vault{Token1.Balance}>()
                        ?? panic("Could not borrow a reference to the receiver")
    
        return [userRef0.balance, userRef1.balance]
    }`,
    `import SimpleMarket from "./../contracts/SimpleMarket.cdc"

    pub fun main(id: UInt32): SimpleMarket.Node? {
        return SimpleMarket.ids[id]
    }`,
    `import SimpleMarket from "./../contracts/SimpleMarket.cdc"

    pub fun main(id: UInt32): [UInt32] {
        return [SimpleMarket.ids[id]?.left!, SimpleMarket.ids[id]?.right!]
    }`,
    `import SimpleMarket from "./../contracts/SimpleMarket.cdc"

    pub fun main(): UInt32 {
        return SimpleMarket.current
    }`
]
