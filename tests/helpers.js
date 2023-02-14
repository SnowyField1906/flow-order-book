export const contractNames = ["OrderBookV6"]

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

export const addressMap = { OrderBookV6: "0xf8d6e0586b0a20c7" }

export const transactionTemplates = [
    ``,
    `import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

    transaction(payAmount: UFix64, buyAmount: UFix64) {
    
        let maker: Address
    
        prepare(acct: AuthAccount) {
            self.maker = acct.address
        }
    
        execute {
            let offer = OrderBookV6.limitOrder(self.maker, payAmount, buyAmount)    
        }
    }`,
    `import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

    transaction(id: UInt32, quantity: UFix64) {
    
        let maker: Address
    
        prepare(acct: AuthAccount) {
            self.maker = acct.address
        }
    
        execute {
            let offer = OrderBookV6.marketOrder(id, quantity)    
        }
    }`
]

export const scriptTemplates = [
    `import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

    pub fun main(): &{UInt32: OrderBookV6.Offer}? {
        return &OrderBookV6.offers as &{UInt32: OrderBookV6.Offer}?
    }`,
    `import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

    pub fun main(): [UInt32] {
        let ids: [UInt32] = []
    
        var current = OrderBookV6.current
        fun inorder(_ current: UInt32) {
            if current == 0 {
                return
            }
            inorder(OrderBookV6.ids[current]?.left!)
            ids.append(current)
            inorder(OrderBookV6.ids[current]?.left!)
        }
    
        return ids
    }`,
    `import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

    pub fun main(): [UFix64] {
        let ids: [UFix64] = []
    
        var current = OrderBookV6.current
        while (current != 0) {
            ids.append(OrderBookV6.getPrice(current))
            current = OrderBookV6.ids[current]!.right
        }
    
        return ids
    }`,
    `import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

    pub fun main(id: UInt32): &OrderBookV6.Offer? {
        return &OrderBookV6.offers[id] as &OrderBookV6.Offer?
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
    `import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

    pub fun main(id: UInt32): OrderBookV6.Node? {
        return OrderBookV6.ids[id]
    }`,
    `import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

    pub fun main(id: UInt32): [UInt32] {
        return [OrderBookV6.ids[id]?.left!, OrderBookV6.ids[id]?.right!]
    }`,
    `import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

    pub fun main(): UInt32 {
        return OrderBookV6.current
    }`,
    `import OrderBookV6 from "./../contracts/OrderBookV6.cdc"

    pub fun main(): [UInt16] {
        return [OrderBookV6.lowerPrices, OrderBookV6.higherPrices]
    }`
]
