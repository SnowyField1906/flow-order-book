// import BinarySearchOffers from 0x9d380238fdd484d7

pub contract SimpleMarket {

    pub var current: Node?
    pub var offers: @{UInt32: Offer}

    init() {
        self.current = nil
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

        if self.current == nil {
            self.current = Node(id)
        }
        else {
            self.insertNode(id)
        }

        return &self.offers[id] as &Offer? 
    }

    /////////////////////////////////////////////

    pub struct Node {
        pub(set) var key  : UInt32
        pub(set) var left : Node?
        pub(set) var right: Node?

        init(_ key: UInt32) {
            self.key = key
            self.left = nil
            self.right = nil
        }
    }

    pub fun comparePrice(_ a: UInt32, _ b: UInt32): Int16 {
        let offer0 = &self.offers[a] as &Offer?
        let offer1 = &self.offers[b] as &Offer?

        log("comparing: ".concat(a.toString()).concat(" and ").concat(b.toString()))

        if offer0 == nil || offer1 == nil {
            log("offer is nil")
            return -2
        }

        if offer0!.payAmount / offer0!.buyAmount > offer1!.payAmount / offer1!.buyAmount {
            log((offer0!.payAmount / offer0!.buyAmount).toString().concat(" and ").concat((offer1!.payAmount / offer1!.buyAmount).toString().concat(" (bigger)")))
            return 1
        }
        else if offer0!.payAmount / offer0!.buyAmount < offer1!.payAmount / offer1!.buyAmount {
            log((offer0!.payAmount / offer0!.buyAmount).toString().concat(" and ").concat((offer1!.payAmount / offer1!.buyAmount).toString().concat(" (smaller)")))
            return -1
        }
        else {
            log((offer0!.payAmount / offer0!.buyAmount).toString().concat(" and ").concat((offer1!.payAmount / offer1!.buyAmount).toString().concat(" (equal)")))
            return 0
        }
    }

    pub fun insertNode(_ key: UInt32) {
        log("starting to insert node: ".concat(key.toString()))

        var root: Node? = self.current
        var newNode: Node = Node(key)

        if self.comparePrice(key, root?.key!) == -1 {
            root = root?.left
            log("looping to left")
            while root != nil && self.comparePrice(key, root?.key!) == -1 {
                root = root?.left
            }
            log("assign node")
            newNode.left = root?.left
            newNode.right = root
            root?.left = newNode
            
        }
        else if self.comparePrice(key, root?.key!) == 1 {
            root = root?.right
            log("looping to right")
            while root != nil && self.comparePrice(key, root?.key!) == 1 {
                root = root?.right
            }
            log("assign node")
            newNode.left = root
            newNode.right = root?.right
            root?.right = newNode
        }

        self.current = root

        log("finished inserting node: ".concat(key.toString()))
    }

    // pub fun deleteNode(_ root: Node, _ key: UInt32): Bool {
    //     var root: Node = self.current!

    //     while root.key < key {
    //         root = root.left!
    //     }
    //     while root.key > key {
    //         root = root.right!
    //     }

    //     if root.key == key {
    //         root.left.right = root.right
    //         root.right.left = root.left
    //         return true
    //     }
    //     return false
    // }

    pub fun inorderTraversal(_ ids: [UInt32], _ root: Node?) {
        if root?.left != nil {
            self.inorderTraversal(ids, root?.left!)
        }
        let offer = &self.offers[root!.key] as &Offer?
        log(root!.key.toString().concat(": ").concat((offer!.payAmount / offer!.buyAmount).toString()))
        ids.append(root!.key)
        if root?.right != nil {
            self.inorderTraversal(ids, root?.right!)
        }
    }
}
 