// import BinarySearchOffers from 0x9d380238fdd484d7

pub contract SimpleMarketv3 {

    pub var current: Node
    pub var offers: @{UInt32: Offer}

    init() {
        self.current = Node(0)
        self.offers <- {}
    }

    pub resource Offer {

        pub      let maker     : Address
        pub      let payToken  : Address
        pub(set) var payAmount : UFix64
        pub      let buyToken  : Address
        pub(set) var buyAmount : UFix64

        init(_ maker: Address, _ payToken: Address, _ payAmount: UFix64, _ buyToken: Address, _ buyAmount: UFix64) {
            self.maker      = maker            
            self.payToken   = payToken
            self.payAmount  = payAmount
            self.buyToken   = buyToken
            self.buyAmount  = buyAmount
        }
    }


    pub fun makeOffer(_ maker: Address, _ payToken: Address, _ payAmount: UFix64, _ buyToken: Address, _ buyAmount: UFix64): &Offer? {
        let id = UInt32(getCurrentBlock().timestamp)
        let newOffer: @Offer <- create Offer(maker, payToken, payAmount, buyToken, buyAmount)
        
        self.offers[id] <-! newOffer
        self.insertNode(id)

        return &self.offers[id] as &Offer? 
    }

    /////////////////////////////////////////////

    pub struct Node {
        pub(set) var key  : UInt32
        pub(set) var left : Node
        pub(set) var right: Node

        init(_ key: UInt32) {
            self.key = key
            self.left = Node(0)
            self.right = Node(0)
        }
    }


    pub fun insertNode(_ key: UInt32) {
        var root: Node = self.current
        var newNode: Node = Node(key)

        if key < root.key {
            while root.key < key {
                root = root.left
            }
            newNode.left = root.left
            newNode.right = root
        }
        else if key > root.key {
            while root.key > key {
                root = root.right
            }
            newNode.left = root
            newNode.right = root.right
        }
    }

    pub fun deleteNode(_ root: Node, _ key: UInt32): Bool {
        var root: Node = self.current

        while root.key < key {
            root = root.left
        }
        while root.key > key {
            root = root.right
        }

        if root.key == key {
            root.left.right = root.right
            root.right.left = root.left
            return true
        }
        return false
    }
}
 