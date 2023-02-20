export const contractNames = ["OrderBookV14"]

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

export const addressMap = { OrderBookV14: "0xf8d6e0586b0a20c7" }

export const transactionTemplates = [
    ``,
    `import OrderBookV14 from "./../contracts/OrderBookV14.cdc"

    transaction(payAmount: UFix64, buyAmount: UFix64) {
    
        let maker: Address
    
        prepare(acct: AuthAccount) {
            self.maker = acct.address
        }
    
        execute {
            let offer = OrderBookV14.limitOrder(self.maker, payAmount, buyAmount)    
        }
    }`,
    `import OrderBookV14 from "./../contracts/OrderBookV14.cdc"

    transaction(id: UInt32, quantity: UFix64) {
    
        let maker: Address
    
        prepare(acct: AuthAccount) {
            self.maker = acct.address
        }
    
        execute {
            let offer = OrderBookV14.marketOrder(id, quantity)    
        }
    }`
]

export const scriptTemplates = [
    `import OrderBookV14 from "./../contracts/OrderBookV14.cdc"

    pub fun main(): &{UInt32: OrderBookV14.Offer}? {
        return &OrderBookV14.offers as &{UInt32: OrderBookV14.Offer}?
    }`,
    `import OrderBookV14 from "./../contracts/OrderBookV14.cdc"

    pub fun main(): [UInt32] {
        let ids: [UInt32] = []
    
        var current = OrderBookV14.current
        fun inorder(_ current: UInt32) {
            if current == 0 {
                return
            }
            inorder(OrderBookV14.ids[current]?.left!)
            ids.append(current)
            inorder(OrderBookV14.ids[current]?.left!)
        }
    
        return ids
    }`,
    `import OrderBookV14 from "./../contracts/OrderBookV14.cdc"

    pub fun main(): [UFix64] {
        let ids: [UFix64] = []
    
        var current = OrderBookV14.current
        while (current != 0) {
            ids.append(OrderBookV14.getPrice(current))
            current = OrderBookV14.ids[current]!.right
        }
    
        return ids
    }`,
    `import OrderBookV14 from "./../contracts/OrderBookV14.cdc"

    pub fun main(id: UInt32): &OrderBookV14.Offer? {
        return &OrderBookV14.offers[id] as &OrderBookV14.Offer?
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
    `import OrderBookV14 from "./../contracts/OrderBookV14.cdc"

    pub fun main(id: UInt32): OrderBookV14.Node? {
        return OrderBookV14.ids[id]
    }`,
    `import OrderBookV14 from "./../contracts/OrderBookV14.cdc"

    pub fun main(id: UInt32): [UInt32] {
        return [OrderBookV14.ids[id]?.left!, OrderBookV14.ids[id]?.right!]
    }`,
    `import OrderBookV14 from "./../contracts/OrderBookV14.cdc"

    pub fun main(): UInt32 {
        return OrderBookV14.current
    }`,
    `import OrderBookV14 from "./../contracts/OrderBookV14.cdc"

    pub fun main(): [UInt16] {
        return [OrderBookV14.lowerPrices, OrderBookV14.higherPrices]
    }`
]
