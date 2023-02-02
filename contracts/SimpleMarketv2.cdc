// import BinarySearchOffers from 0x9d380238fdd484d7

pub contract SimpleMarketv2 {

    pub var root: Node
    pub var offers: @{UInt32: Offer}
    pub var users: @{Address: User}

    init() {
        self.root = Node(0)
        self.offers <- {}
        self.users <- {}
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


    pub resource interface HasOwnedOffer {

        pub var ownedMake: [UInt32]
        pub var ownedTake: [UInt32]

        pub fun made(_ id: UInt32)
        pub fun taken(_ id: UInt32)
    }


    pub resource User: HasOwnedOffer {

        pub var ownedMake: [UInt32]
        pub var ownedTake: [UInt32]

        init() {

            self.ownedMake = []
            self.ownedTake = []
        }

        pub fun made(_ id: UInt32) {
            self.ownedMake.append(id)
        }

        pub fun taken(_ id: UInt32) {
            self.ownedTake.append(id)
        }

    }

    pub fun makeOffer(_ maker: Address, _ payToken: Address, _ payAmount: UFix64, _ buyToken: Address, _ buyAmount: UFix64): &Offer? {
        let id = UInt32(getCurrentBlock().timestamp)
        let newOffer: @Offer <- create Offer(maker, payToken, payAmount, buyToken, buyAmount)
        let newNode: Node = Node(id)
        
        self.offers[id] <-! newOffer
        self.insertNode(newNode, id)

        return &self.offers[id] as &Offer? 
    }

    pub fun createUser(): @User {
        return <- create User()
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


    pub fun insertNode(_ root: Node, _ key: UInt32): Node {
        if root.key == 0 {
            return Node(key)
        }

        let offerRef: &Offer? = &self.offers[key] as &Offer?
        let rootRef: &Offer? = &self.offers[root.key] as &Offer?

        let offerPrice: UFix64 = offerRef!.payAmount / offerRef!.buyAmount
        let rootPrice: UFix64 = rootRef!.payAmount / rootRef!.buyAmount

        if rootPrice < offerPrice {
            root.right = self.insertNode(root.right, key)
        }
        if rootPrice > offerPrice {
            root.left = self.insertNode(root.left, key)
        }

        return root
    }

    pub fun findNode(_ root: Node, _ key: UInt32): Node {
        if root.key == 0 {
            return Node(0)
        }

        if root.key == key {
            return root
        }

        let offerRef: &Offer? = &self.offers[key] as &Offer?
        let rootRef: &Offer? = &self.offers[root.key] as &Offer?

        let offerPrice: UFix64 = offerRef!.payAmount / offerRef!.buyAmount
        let rootPrice: UFix64 = rootRef!.payAmount / rootRef!.buyAmount

        if rootPrice < offerPrice {
            return self.findNode(root.right, key)
        }
        if rootPrice > offerPrice {
            return self.findNode(root.left, key)
        }

        return Node(0)
    }

    pub fun getRightMin(root: Node): UInt32 {
        var temp: Node = root
        while temp.left.key != 0 {
            temp = temp.left
        }

        return temp.key
    }

    pub fun deleteNode(_ root: Node, _ key: UInt32): Node {
        if root.key == 0 {
            return Node(0)
        }

        if root.key < key {
            root.right = self.deleteNode(root.right, key)
        }

        else if root.key > key {
            root.left = self.deleteNode(root.left, key)
        }

        else {
            if root.left.key == 0 && root.right.key == 0 {
                root.key = 0
                return Node(0)
            }

            else if root.left.key == 0 {
                let temp: Node = root.right
                root.key = 0
                return temp
            }

            else if root.right.key == 0 {
                let temp: Node = root.left
                root.key = 0
                return temp
            }

            else {
                let min: UInt32 = self.getRightMin(root: root.right)
                root.key = min
                root.right = self.deleteNode(root.right, min)
            }
        }

        return root
    }

    pub fun inorderTraversal(_ offers: [UInt32], _ root: Node) {
        if root.key == 0 {
            return
        }
        self.inorderTraversal(offers, root.left)
        offers.append(root.key)
        self.inorderTraversal(offers, root.right)
    }
}