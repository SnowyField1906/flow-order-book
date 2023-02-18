export const contractNames = ["OrderBookV10"]

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

export const addressMap = { OrderBookV10: "0xf8d6e0586b0a20c7" }

export const transactionTemplates = [
    ``,
    `import OrderBookV10 from "./../contracts/OrderBookV10.cdc"

    transaction(payAmount: UFix64, buyAmount: UFix64) {
    
        let maker: Address
    
        prepare(acct: AuthAccount) {
            self.maker = acct.address
        }
    
        execute {
            let offer = OrderBookV10.limitOrder(self.maker, payAmount, buyAmount)    
        }
    }`,
    `import OrderBookV10 from "./../contracts/OrderBookV10.cdc"

    transaction(id: UInt32, quantity: UFix64) {
    
        let maker: Address
    
        prepare(acct: AuthAccount) {
            self.maker = acct.address
        }
    
        execute {
            let offer = OrderBookV10.marketOrder(id, quantity)    
        }
    }`
]

export const scriptTemplates = [
    `import OrderBookV10 from "./../contracts/OrderBookV10.cdc"

    pub fun main(): &{UInt32: OrderBookV10.Offer}? {
        return &OrderBookV10.offers as &{UInt32: OrderBookV10.Offer}?
    }`,
    `import OrderBookV10 from "./../contracts/OrderBookV10.cdc"

    pub fun main(): [UInt32] {
        let ids: [UInt32] = []
    
        var current = OrderBookV10.current
        fun inorder(_ current: UInt32) {
            if current == 0 {
                return
            }
            inorder(OrderBookV10.ids[current]?.left!)
            ids.append(current)
            inorder(OrderBookV10.ids[current]?.left!)
        }
    
        return ids
    }`,
    `import OrderBookV10 from "./../contracts/OrderBookV10.cdc"

    pub fun main(): [UFix64] {
        let ids: [UFix64] = []
    
        var current = OrderBookV10.current
        while (current != 0) {
            ids.append(OrderBookV10.getPrice(current))
            current = OrderBookV10.ids[current]!.right
        }
    
        return ids
    }`,
    `import OrderBookV10 from "./../contracts/OrderBookV10.cdc"

    pub fun main(id: UInt32): &OrderBookV10.Offer? {
        return &OrderBookV10.offers[id] as &OrderBookV10.Offer?
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
    `import OrderBookV10 from "./../contracts/OrderBookV10.cdc"

    pub fun main(id: UInt32): OrderBookV10.Node? {
        return OrderBookV10.ids[id]
    }`,
    `import OrderBookV10 from "./../contracts/OrderBookV10.cdc"

    pub fun main(id: UInt32): [UInt32] {
        return [OrderBookV10.ids[id]?.left!, OrderBookV10.ids[id]?.right!]
    }`,
    `import OrderBookV10 from "./../contracts/OrderBookV10.cdc"

    pub fun main(): UInt32 {
        return OrderBookV10.current
    }`,
    `import OrderBookV10 from "./../contracts/OrderBookV10.cdc"

    pub fun main(): [UInt16] {
        return [OrderBookV10.lowerPrices, OrderBookV10.higherPrices]
    }`
]
