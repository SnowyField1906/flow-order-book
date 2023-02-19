export const contractNames = ["OrderBookV13"]

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

export const addressMap = { OrderBookV13: "0xf8d6e0586b0a20c7" }

export const transactionTemplates = [
    ``,
    `import OrderBookV13 from "./../contracts/OrderBookV13.cdc"

    transaction(payAmount: UFix64, buyAmount: UFix64) {
    
        let maker: Address
    
        prepare(acct: AuthAccount) {
            self.maker = acct.address
        }
    
        execute {
            let offer = OrderBookV13.limitOrder(self.maker, payAmount, buyAmount)    
        }
    }`,
    `import OrderBookV13 from "./../contracts/OrderBookV13.cdc"

    transaction(id: UInt32, quantity: UFix64) {
    
        let maker: Address
    
        prepare(acct: AuthAccount) {
            self.maker = acct.address
        }
    
        execute {
            let offer = OrderBookV13.marketOrder(id, quantity)    
        }
    }`
]

export const scriptTemplates = [
    `import OrderBookV13 from "./../contracts/OrderBookV13.cdc"

    pub fun main(): &{UInt32: OrderBookV13.Offer}? {
        return &OrderBookV13.offers as &{UInt32: OrderBookV13.Offer}?
    }`,
    `import OrderBookV13 from "./../contracts/OrderBookV13.cdc"

    pub fun main(): [UInt32] {
        let ids: [UInt32] = []
    
        var current = OrderBookV13.current
        fun inorder(_ current: UInt32) {
            if current == 0 {
                return
            }
            inorder(OrderBookV13.ids[current]?.left!)
            ids.append(current)
            inorder(OrderBookV13.ids[current]?.left!)
        }
    
        return ids
    }`,
    `import OrderBookV13 from "./../contracts/OrderBookV13.cdc"

    pub fun main(): [UFix64] {
        let ids: [UFix64] = []
    
        var current = OrderBookV13.current
        while (current != 0) {
            ids.append(OrderBookV13.getPrice(current))
            current = OrderBookV13.ids[current]!.right
        }
    
        return ids
    }`,
    `import OrderBookV13 from "./../contracts/OrderBookV13.cdc"

    pub fun main(id: UInt32): &OrderBookV13.Offer? {
        return &OrderBookV13.offers[id] as &OrderBookV13.Offer?
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
    `import OrderBookV13 from "./../contracts/OrderBookV13.cdc"

    pub fun main(id: UInt32): OrderBookV13.Node? {
        return OrderBookV13.ids[id]
    }`,
    `import OrderBookV13 from "./../contracts/OrderBookV13.cdc"

    pub fun main(id: UInt32): [UInt32] {
        return [OrderBookV13.ids[id]?.left!, OrderBookV13.ids[id]?.right!]
    }`,
    `import OrderBookV13 from "./../contracts/OrderBookV13.cdc"

    pub fun main(): UInt32 {
        return OrderBookV13.current
    }`,
    `import OrderBookV13 from "./../contracts/OrderBookV13.cdc"

    pub fun main(): [UInt16] {
        return [OrderBookV13.lowerPrices, OrderBookV13.higherPrices]
    }`
]
