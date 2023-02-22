export const contractNames = ["OrderBookV16"]

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

export const addressMap = { OrderBookV16: "0xf8d6e0586b0a20c7" }

export const transactionTemplates = [
    ``,
    `import OrderBookV16 from "./../contracts/OrderBookV16.cdc"

    transaction(payAmount: UFix64, buyAmount: UFix64) {
    
        let maker: Address
    
        prepare(acct: AuthAccount) {
            self.maker = acct.address
        }
    
        execute {
            let offer = OrderBookV16.limitOrder(self.maker, payAmount, buyAmount)    
        }
    }`,
    `import OrderBookV16 from "./../contracts/OrderBookV16.cdc"

    transaction(id: UInt32, quantity: UFix64) {
    
        let maker: Address
    
        prepare(acct: AuthAccount) {
            self.maker = acct.address
        }
    
        execute {
            let offer = OrderBookV16.marketOrder(id, quantity)    
        }
    }`
]

export const scriptTemplates = [
    `import OrderBookV16 from "./../contracts/OrderBookV16.cdc"

    pub fun main(): &{UInt32: OrderBookV16.Offer}? {
        return &OrderBookV16.offers as &{UInt32: OrderBookV16.Offer}?
    }`,
    `import OrderBookV16 from "./../contracts/OrderBookV16.cdc"

    pub fun main(): [UInt32] {
        let ids: [UInt32] = []
    
        var current = OrderBookV16.current
        fun inorder(_ current: UInt32) {
            if current == 0 {
                return
            }
            inorder(OrderBookV16.ids[current]?.left!)
            ids.append(current)
            inorder(OrderBookV16.ids[current]?.left!)
        }
    
        return ids
    }`,
    `import OrderBookV16 from "./../contracts/OrderBookV16.cdc"

    pub fun main(): [UFix64] {
        let ids: [UFix64] = []
    
        var current = OrderBookV16.current
        while (current != 0) {
            ids.append(OrderBookV16.getPrice(current))
            current = OrderBookV16.ids[current]!.right
        }
    
        return ids
    }`,
    `import OrderBookV16 from "./../contracts/OrderBookV16.cdc"

    pub fun main(id: UInt32): &OrderBookV16.Offer? {
        return &OrderBookV16.offers[id] as &OrderBookV16.Offer?
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
    `import OrderBookV16 from "./../contracts/OrderBookV16.cdc"

    pub fun main(id: UInt32): OrderBookV16.Node? {
        return OrderBookV16.ids[id]
    }`,
    `import OrderBookV16 from "./../contracts/OrderBookV16.cdc"

    pub fun main(id: UInt32): [UInt32] {
        return [OrderBookV16.ids[id]?.left!, OrderBookV16.ids[id]?.right!]
    }`,
    `import OrderBookV16 from "./../contracts/OrderBookV16.cdc"

    pub fun main(): UInt32 {
        return OrderBookV16.current
    }`,
    `import OrderBookV16 from "./../contracts/OrderBookV16.cdc"

    pub fun main(): [UInt16] {
        return [OrderBookV16.lowerPrices, OrderBookV16.higherPrices]
    }`
]
