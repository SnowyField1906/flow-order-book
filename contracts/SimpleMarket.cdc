pub contract SimpleMarket {
    pub var current: UInt32
    pub let ids: {UInt32: Node}
    pub let offers: @{UInt32: Offer}

    init() {
        self.current = 0
        self.ids = {}
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
        let id: UInt32 = UInt32(getCurrentBlock().timestamp)
        let newOffer: @Offer <- create Offer(maker, payToken, payAmount, buyToken, buyAmount)
        
        self.offers[id] <-! newOffer

        self.ids[id] = self.insertNode(id)

        return &self.offers[id] as &Offer? 
    }

    /////////////////////////////////////////////

    pub struct Node {
        pub(set) var left : UInt32
        pub(set) var right: UInt32

        init(left: UInt32, right: UInt32) {
            self.left = left
            self.right = right
        }
    }

    pub fun insertNode(_ id: UInt32): Node {
        if self.current == 0 {
            log("inserted first node: ".concat(id.toString()))
            self.current = id 
            return Node(left: 0, right: 0)
        }

        log("starting to insert node: ".concat(id.toString()))
        
        var curr: UInt32 = self.current
        var left: UInt32 = 0
        var right: UInt32 = 0

        if self.comparePrice(curr, id) == -1 {

            log("looping to right")
            while self.ids[curr]?.right != 0 && self.comparePrice(self.ids[curr]!.right, id) == -1 {
                curr = self.ids[curr]!.right
            }

            log("assigning new node")
            let next: UInt32 = self.ids[curr]!.right
            left = curr
            right = next != 0 ? next : 0
            
            log("assigning old nodes")
            self.ids[curr] = Node(left: self.ids[curr]!.left, right: id)
            if next != 0 {
                self.ids[next] = Node(left: id, right: self.ids[next]!.right)
            }
        }
        else if self.comparePrice(curr, id) == 1 {
        
            log("looping to left")
            while self.ids[curr]?.left != 0 && self.comparePrice(self.ids[curr]!.left, id) == -1 {
                curr = self.ids[curr]!.left
            }

            log("assigning new node")
            let next: UInt32 = self.ids[curr]!.left
            left = next != 0 ? next : 0
            right = curr
        
            log("assigning old nodes")
            self.ids[curr] = Node(left: id, right: self.ids[curr]!.right)
            if next != 0 {
                self.ids[next] = Node(left: self.ids[next]!.left, right: id)
            }
        }

        log("inserted node: ".concat(id.toString()))

        return Node(left: left, right: right)
    }

    pub fun comparePrice(_ a: UInt32, _ b: UInt32): Int16 {
        let offer0: &SimpleMarket.Offer? = &self.offers[a] as &Offer?
        let offer1: &SimpleMarket.Offer? = &self.offers[b] as &Offer?

        log("comparing: ".concat(a.toString()).concat(" and ").concat(b.toString()))

        if offer0 == nil || offer1 == nil {
            log("offer is nil")
            return -2
        }

        if offer0!.payAmount / offer0!.buyAmount > offer1!.payAmount / offer1!.buyAmount {
            log((offer0!.payAmount / offer0!.buyAmount).toString().concat(" and ").concat((offer1!.payAmount / offer1!.buyAmount).toString().concat(": bigger")))
            return 1
        }
        else if offer0!.payAmount / offer0!.buyAmount < offer1!.payAmount / offer1!.buyAmount {
            log((offer0!.payAmount / offer0!.buyAmount).toString().concat(" and ").concat((offer1!.payAmount / offer1!.buyAmount).toString().concat(": smaller")))
            return -1
        }
        else {
            log((offer0!.payAmount / offer0!.buyAmount).toString().concat(" and ").concat((offer1!.payAmount / offer1!.buyAmount).toString().concat(": equal")))
            return 0
        }
    }

    pub fun inorderTraversal(_ current: UInt32) {
        if SimpleMarket.ids[current] == nil {
            return
        }
        self.inorderTraversal(SimpleMarket.ids[current]!.left)
        log(current)
        self.inorderTraversal(SimpleMarket.ids[current]!.right)
    }
}
 