export const contractNames = ["OrderBook"]

export const scriptNames = [
    "0. Load ordered offer list",
    "1. Load ordered id list",
    "2. Load sorted id list",
    "3. Load offer detail",
    "4. Load id detail",
    "5. Load current offer",
    "6. Load current id",
]

export const transactionNames = [
    "0. Setup account",
    "1. Make offer",
    "2. Buy",
]

export const addressMap = { OrderBook: "0xf8d6e0586b0a20c7" }

export const transactionTemplates = [
    ``,
    `import OrderBook from "./../contracts/OrderBook.cdc"

    transaction(payAmount: UFix64, buyAmount: UFix64) {
    
        let maker: Address
    
        prepare(acct: AuthAccount) {
            self.maker = acct.address
        }
    
        execute {
            let offer = OrderBook.makeOffer(self.maker, payAmount, buyAmount)    
        }
    }`,
    `import OrderBook from "./../contracts/OrderBook.cdc"

    transaction(id: UInt32, quantity: UFix64) {
    
        let maker: Address
    
        prepare(acct: AuthAccount) {
            self.maker = acct.address
        }
    
        execute {
            let offer = OrderBook.buy(id, quantity)    
        }
    }`
]

export const scriptTemplates = [
    `import OrderBook from "./../contracts/OrderBook.cdc"

    pub fun main(): &{UInt32: OrderBook.Offer}? {
        return &OrderBook.offers as &{UInt32: OrderBook.Offer}?
    }`,
    `import OrderBook from "./../contracts/OrderBook.cdc"

    pub fun main(): [UInt32] {
        let ids: [UInt32] = []
    
        var current = OrderBook.current
        fun inorder(_ current: UInt32) {
            if current == 0 {
                return
            }
            inorder(OrderBook.ids[current]?.left!)
            ids.append(current)
            inorder(OrderBook.ids[current]?.left!)
        }
    
        return ids
    }`,
    `import OrderBook from "./../contracts/OrderBook.cdc"

    pub fun main(): [UFix64] {
        let ids: [UFix64] = []
    
        var current = OrderBook.current
        while (current != 0) {
            ids.append(OrderBook.getPrice(current))
            current = OrderBook.ids[current]!.right
        }
    
        return ids
    }`,
    `import OrderBook from "./../contracts/OrderBook.cdc"

    pub fun main(id: UInt32): &OrderBook.Offer? {
        return &OrderBook.offers[id] as &OrderBook.Offer?
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
    `import OrderBook from "./../contracts/OrderBook.cdc"

    pub fun main(id: UInt32): OrderBook.Node? {
        return OrderBook.ids[id]
    }`,
    `import OrderBook from "./../contracts/OrderBook.cdc"

    pub fun main(id: UInt32): [UInt32] {
        return [OrderBook.ids[id]?.left!, OrderBook.ids[id]?.right!]
    }`,
    `import OrderBook from "./../contracts/OrderBook.cdc"

    pub fun main(): UInt32 {
        return OrderBook.current
    }`,
    `import OrderBook from "./../contracts/OrderBook.cdc"

    pub fun main(): [UInt16] {
        return [OrderBook.lowerPrices, OrderBook.higherPrices]
    }`
]
