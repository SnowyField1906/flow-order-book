pub contract OrderBookV21 {
    
    pub let offers:       @{UInt32: Offer}
    pub let ids:           {UInt32: Node}
    pub var current:        UInt32
    pub var lowerPrices:    UInt16
    pub var higherPrices:   UInt16

    init() {
        self.current = 0
        self.ids = {}
        self.offers <- {}
        self.lowerPrices = 0
        self.higherPrices = 0
    }

    pub resource Offer {
        pub      let maker     : Address
        pub      let payToken  : Address
        pub(set) var payAmount : UFix64
        pub      let buyToken  : Address
        pub(set) var buyAmount : UFix64

        init(_ maker   : Address,
            _ payToken: Address, _ payAmount: UFix64,
            _ buyToken: Address, _ buyAmount: UFix64
        ) {
            self.maker      = maker
            self.payToken   = payToken
            self.payAmount  = payAmount
            self.buyToken   = buyToken
            self.buyAmount  = buyAmount
        }
    }

    pub fun limitOrder(_ maker: Address, _ payToken: Address,
        _ payAmount: UFix64, _ buyToken: Address, _ buyAmount: UFix64
    ): &Offer? {
        let id: UInt32 = UInt32(getCurrentBlock().timestamp)
        let newOffer: @Offer <- create Offer(
            maker, payToken, payAmount, buyToken, buyAmount
        )
        
        self.offers[id] <-! newOffer

        self.ids[id] = self.insertNode(id)

        return &self.offers[id] as &Offer? 
    }

    pub fun marketOrder(_ id: UInt32, _ quantity: UFix64) {
        let cost     : UFix64 = self.offers[id]?.buyAmount! * quantity / self.offers[id]?.payAmount!
        let payAmount: UFix64 = self.offers[id]?.payAmount! - quantity
        let buyAmount: UFix64 = self.offers[id]?.buyAmount! - cost

        if payAmount == 0.0 || buyAmount == 0.0 {
            self.removeNode(id)
            destroy self.offers.remove(key: id)
        }
        else {
            var offer: @Offer? <- create Offer(
                self.offers[id]?.maker!,
                self.offers[id]?.payToken!,
                payAmount,
                self.offers[id]?.buyToken!,
                buyAmount
            )
            self.offers[id] <-> offer
            destroy offer
        }
    }

    pub fun matchingPrice(payAmount: UFix64, buyAmount: UFix64): UInt32 {
        let price: UFix64 = buyAmount / payAmount
        var curr : UInt32 = self.current
        var left : UInt32 = 0
        var right: UInt32 = 0

        if self.getPrice(curr) == price {
            return curr
        }
        else if self.getPrice(curr) < price {
            while self.ids[curr]?.right != 0 &&
                self.getPrice(self.ids[curr]!.right) < price
            {
                curr = self.ids[curr]!.right
            }

            return curr
        }
        else if self.getPrice(curr) > price {
            while self.ids[curr]?.left != 0 &&
                self.getPrice(self.ids[curr]!.left) > price
            {
                curr = self.ids[curr]!.left
            }

            return curr
        }
        return 0
    }

    pub fun getPrice(_ id: UInt32): UFix64 {
        let offer: &Offer? = &self.offers[id] as &Offer?
        return offer!.buyAmount / offer!.payAmount
    }

    /////////////////////////////////////////////

    pub struct Node {
        pub(set) var left : UInt32
        pub(set) var right: UInt32

        init(left: UInt32, right: UInt32) {
            self.left  = left
            self.right = right
        }
    }

    pub fun insertNode(_ id: UInt32): Node {

        if self.current == 0 {
            self.current = id 

            return Node(left: 0, right: 0)
        }

        var curr : UInt32 = self.current
        var left : UInt32 = 0
        var right: UInt32 = 0

        if self.comparePrice(curr, id) == -1 {

            while self.ids[curr]?.right != 0 &&
                self.comparePrice(self.ids[curr]!.right, id) == -1
            {
                curr = self.ids[curr]!.right
            }

            let next: UInt32 = self.ids[curr]!.right
            left  = curr
            right = next != 0 ? next : 0
            
            self.ids[curr] = Node(
                left: self.ids[curr]!.left, right: id
            )
            if next != 0 {
                self.ids[next] = Node(
                    left: id, right: self.ids[next]!.right
                )
            }

            self.higherPrices = self.higherPrices + 1
        }
        else if self.comparePrice(curr, id) == 1 {
        
            while self.ids[curr]?.left != 0 &&
                self.comparePrice(self.ids[curr]!.left, id) == -1 {
                curr = self.ids[curr]!.left
            }

            let next: UInt32 = self.ids[curr]!.left
            left = next != 0 ? next : 0
            right = curr
        
            self.ids[curr] = Node(
                left: id, right: self.ids[curr]!.right
            )
            if next != 0 {
                self.ids[next] = Node(
                    left: self.ids[next]!.left, right: id
                )
            }

            self.lowerPrices = self.lowerPrices + 1
        }


        return Node(left: left, right: right)
    }

    pub fun removeNode(_ id: UInt32) {

        if self.current == id {
            let left : UInt32 = self.ids[id]!.left
            let right: UInt32 = self.ids[id]!.right

            if right != 0 && self.higherPrices - self.lowerPrices >= 0 {
                self.ids[right] = Node(
                    left: left, right: self.ids[right]!.right
                )
                if left != 0 {
                    self.ids[left] = Node(
                        left: self.ids[left]!.left, right: right
                    )
                }

                self.current = right
                self.higherPrices = self.higherPrices - 1
            }
            else if left != 0 && self.higherPrices - self.lowerPrices < 0 {
                self.ids[left] = Node(
                    left: self.ids[left]!.left, right: right
                )
                if right != 0 {
                    self.ids[right] = Node(
                        left: left, right: self.ids[right]!.right
                    )
                }

                self.current = left
                self.lowerPrices = self.lowerPrices - 1
            }
            else {
                self.current = 0
            }
            return
        }
        
        var curr: UInt32 = self.current

        if self.comparePrice(curr, id) == -1 {

            while curr != id {
                curr = self.ids[curr]!.right
            }

            let left : UInt32 = self.ids[id]!.left
            let right: UInt32 = self.ids[id]!.right
            self.ids[left] = Node(
                left: self.ids[left]!.left, right: right
            )
            if right != 0 {
                self.ids[right] = Node(
                    left: left, right: self.ids[right]!.right
                )
            }

            self.higherPrices = self.higherPrices - 1
        }
        else if self.comparePrice(curr, id) == 1 {

            while curr != id {
                curr = self.ids[curr]!.left
            }

            let left : UInt32 = self.ids[id]!.left
            let right: UInt32 = self.ids[id]!.right
            self.ids[right] = Node(
                left: left, right: self.ids[right]!.right
            )
            if left != 0 {
                self.ids[left] = Node(
                    left: self.ids[left]!.left, right: right
                )
            }

            self.lowerPrices = self.lowerPrices - 1
        }


        return
    }

    pub fun comparePrice(_ a: UInt32, _ b: UInt32): Int16 {
        let offer0: &OrderBookV21.Offer? = &self.offers[a] as &Offer?
        let offer1: &OrderBookV21.Offer? = &self.offers[b] as &Offer?


        if offer0 == nil || offer1 == nil {
            return -2
        }

        if self.getPrice(a) > self.getPrice(b) {
            return 1
        }
        else if self.getPrice(a) < self.getPrice(b) {
            return -1
        }
        else {
            return 0
        }
    }

    pub fun inorderTraversal(_ current: UInt32) {
        if OrderBookV21.ids[current] == nil {
            return
        }
        self.inorderTraversal(OrderBookV21.ids[current]!.left)
        log(current)
        self.inorderTraversal(OrderBookV21.ids[current]!.right)
    }
}
 