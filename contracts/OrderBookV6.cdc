pub contract OrderBookV6 {
    pub var current: UFix64
    pub let bidTree : RedBlackTree
    pub let askTree : RedBlackTree
    pub let bidOffers : {UFix64: Offer}
    pub let askOffers : {UFix64: Offer}

    init() {
        self.current = 0.0
        self.bidTree = RedBlackTree()
        self.askTree = RedBlackTree()
        self.bidOffers = {}
        self.askOffers = {}
    }

    pub fun limitOrder(_ maker: Address, price: UFix64, amount: UFix64, isBid: Bool) {
        let price: UFix64 = price
        
        if self.current == 0.0 {
            self.current = price
        }
        if isBid {
            if !self.askTree.exists(key: price) {
                self.bidOffers[price] = Offer(maker, amount: amount)
                self.bidTree.insert(key: price)
                return
            }
                        
            if self.askOffers[price]!.amount > amount {
                self.askOffers[price]!.changeAmount(amount: self.askOffers[price]!.amount - amount)
                return
            }

            if self.askOffers[price]!.amount < amount {
                self.bidOffers[price] = Offer(maker, amount: amount - self.askOffers[price]!.amount)
                self.bidTree.insert(key: price)
            }

            self.askTree.remove(key: price)
            self.askOffers.remove(key: price)
        }
        else {
            if !self.bidTree.exists(key: price) {
                self.askOffers[price] = Offer(maker, amount: amount)
                self.askTree.insert(key: price)
                return
            }
            
            if self.bidOffers[price]!.amount > amount {
                self.bidOffers[price]!.changeAmount(amount: self.bidOffers[price]!.amount - amount)
                return
            }

            if self.bidOffers[price]!.amount < amount {
                self.askOffers[price] = Offer(maker, amount: amount - self.bidOffers[price]!.amount)
                self.askTree.insert(key: price)
            }
            
            self.bidTree.remove(key: price)
            self.bidOffers.remove(key: price)
        }
    }

    pub fun marketOrder(quantity: UFix64, isBid: Bool) {
        var _quantity: UFix64 = quantity
        var pay: UFix64 = 0.0
        var price: UFix64 = self.current

        if isBid {
            while _quantity > 0.0 && price != 0.0 {
                if self.askOffers[price]!.amount <= _quantity {
                    pay = pay + self.askOffers[price]!.amount * price
                    _quantity = _quantity - self.askOffers[price]!.amount
                    price = self.askTree.next(target: price)
                    self.askTree.remove(key: price)
                    self.askOffers.remove(key: price)
                } else {
                    self.askOffers[price]!.changeAmount(amount: self.askOffers[price]!.amount - _quantity)
                    pay = pay + _quantity / price
                    break
                }
            }
        }
        else {
            while _quantity > 0.0 && price != 0.0 {
                if self.bidOffers[price]!.amount <= _quantity {
                    pay = pay + self.bidOffers[price]!.amount * price
                    _quantity = _quantity - self.bidOffers[price]!.amount
                    price = self.askTree.next(target: price)
                    self.askTree.remove(key: price)
                    self.bidOffers.remove(key: price)
                } else {
                    self.bidOffers[price]!.changeAmount(amount: self.bidOffers[price]!.amount - _quantity)
                    pay = pay + _quantity / price
                    break
                }
            }
        }
        self.current = price
    }


    pub struct Offer {
        pub      let maker     : Address
        pub(set) var amount : UFix64

        init(_ maker : Address, amount: UFix64) {
            self.maker   = maker
            self.amount  = amount
        }

        pub fun changeAmount(amount: UFix64) {
            self.amount = amount
        }
    }

    pub struct Node {
        pub var parent: UFix64
        pub var left:   UFix64
        pub var right:  UFix64
        pub var red:  Bool

        init(parent: UFix64, left: UFix64, right: UFix64, red: Bool) {
            self.parent = parent
            self.left = left
            self.right = right
            self.red = red
        }

        pub fun changeParent(parent: UFix64) {
            self.parent = parent
        }

        pub fun changeLeft(left: UFix64) {
            self.left = left
        }

        pub fun changeRight(right: UFix64) {
            self.right = right
        }

        pub fun changeColor(red: Bool) {
            self.red = red
        }
    }

    pub struct RedBlackTree {
        priv var EMPTY: UFix64

        pub(set) var root: UFix64
        pub(set) var nodes: {UFix64: Node}

            
        init() {
            self.EMPTY = 0.0
            self.root = self.EMPTY
            self.nodes = {0.0 : OrderBookV6.Node(parent: 0.0, left: 0.0, right: 0.0, red: false)}
        }


        ////


        pub fun first(): UFix64 {
            var key: UFix64 = self.root
            if key != self.EMPTY {
                key = self.treeMinimum(key: key)
            }
            return key
        }

        pub fun last(): UFix64 {
            var key: UFix64 = self.root
            if key != self.EMPTY {
                key = self.treeMaximum(key: key)
            }
            return key
        }

        pub fun next(target: UFix64): UFix64 {
            assert(target != self.EMPTY, message: "Target is empty")
            if self.nodes[target]!.right != self.EMPTY {
                return self.treeMinimum(key: self.nodes[target]!.right)
            } else {
                var cursor: UFix64 = self.nodes[target]!.parent
                var _target: UFix64 = target
                while cursor != self.EMPTY && _target == self.nodes[cursor]!.right {
                    _target = cursor
                    cursor = self.nodes[cursor]!.parent
                }
                return cursor
            }
        }

        pub fun prev(target: UFix64): UFix64 {
            assert(target != self.EMPTY, message: "Target is empty")
            if self.nodes[target]!.left != self.EMPTY {
                return self.treeMaximum(key: self.nodes[target]!.left)
            } else {
                var cursor: UFix64 = self.nodes[target]!.parent
                var _target: UFix64 = target
                while cursor != self.EMPTY && _target == self.nodes[cursor]!.left {
                    _target = cursor
                    cursor = self.nodes[cursor]!.parent
                }
                return cursor
            }
        }

        pub fun exists(key: UFix64): Bool {
            return (key != self.EMPTY && self.nodes[key] != nil)
        }


        ////  


        pub fun insert(key: UFix64) {
            assert(key != self.EMPTY, message: "Key is empty")
            assert(!self.exists(key: key), message: "Key already exists")

            var cursor: UFix64 = self.EMPTY
            var probe: UFix64 = self.root

            while probe != self.EMPTY {
                cursor = probe
                probe = key < probe
                    ? self.nodes[probe]!.left
                    : self.nodes[probe]!.right
            }

            self.nodes[key] = Node(
                parent: cursor,
                left: self.EMPTY,
                right: self.EMPTY,
                red: true
            );

            if cursor == self.EMPTY {
                self.root = key
            }
            else {
                key < cursor
                ? self.nodes[cursor]?.changeLeft(left: key)
                : self.nodes[cursor]?.changeRight(right: key)
            }

            self._insertFixup(key: key)
        }


        pub fun remove(key: UFix64) {
            assert(key != self.EMPTY, message: "Key is empty")
            assert(self.exists(key: key), message: "Key does not exist")

            var cursor: UFix64 = key
            var probe: UFix64 = self.EMPTY

            if self.nodes[key]!.left == self.EMPTY || self.nodes[key]!.right == self.EMPTY {
                cursor = key
            } else {
                cursor = self.nodes[key]?.right!
                while (self.nodes[cursor]?.left != self.EMPTY) {
                    cursor = self.nodes[cursor]?.left!
                }
            }

            probe = self.nodes[cursor]?.left != self.EMPTY 
                ? self.nodes[cursor]?.left!
                : self.nodes[cursor]?.right!

            var yParent: UFix64 = self.nodes[cursor]?.parent!
            self.nodes[probe]?.changeParent(parent: yParent)

            if yParent != self.EMPTY {
                cursor == self.nodes[yParent]?.left
                    ? self.nodes[yParent]?.changeLeft(left: probe)
                    : self.nodes[yParent]?.changeRight(right: probe)
            } else {
                self.root = probe
            }

            if cursor != key {
                self._replaceParent(a: cursor, b: key)
                self.nodes[cursor]?.changeLeft(left: self.nodes[key]?.left!)
                self.nodes[self.nodes[cursor]?.left!]?.changeParent(parent: cursor)
                self.nodes[cursor]?.changeRight(right: self.nodes[key]?.right!)
                self.nodes[self.nodes[cursor]?.right!]?.changeParent(parent: cursor)
                self.nodes[cursor]?.changeColor(red: self.nodes[key]?.red!)
            }
            
            if !self.nodes[cursor]?.red! {
                self._removeFixup(key: probe)
            }

            self.nodes.remove(key: key)
        }


        ////


        pub fun treeMinimum(key: UFix64): UFix64 {
            var _key = key

            while self.nodes[_key]!.left != self.EMPTY {
                _key = self.nodes[_key]!.left
            }

            return _key
        }


        pub fun treeMaximum(key: UFix64): UFix64 {
            var _key = key

            while self.nodes[_key]!.right != self.EMPTY {
                _key = self.nodes[_key]!.right
            }

            return key
        }



        priv fun _rotateLeft(key: UFix64) {
            var cursor: UFix64 = self.nodes[key]?.right!
            var keyParent: UFix64 = self.nodes[key]?.parent!
            var cursorLeft: UFix64 = self.nodes[cursor]?.left!
            
            if cursorLeft != self.EMPTY {
                self.nodes[cursorLeft]?.changeParent(parent: key)
            }

            if keyParent == self.EMPTY {
                self.root = cursor
            } else {
                key == self.nodes[keyParent]?.left!
                ? self.nodes[keyParent]?.changeLeft(left: cursor)
                : self.nodes[keyParent]?.changeRight(right: cursor)
            }

            self.nodes[cursor]?.changeParent(parent: keyParent)
            self.nodes[cursor]?.changeLeft(left: key)
            
            self.nodes[key]?.changeParent(parent: cursor)
            self.nodes[key]?.changeRight(right: cursorLeft)

        }

        priv fun _rotateRight(key: UFix64) {
            var cursor: UFix64 = self.nodes[key]?.left!
            var keyParent: UFix64 = self.nodes[key]?.parent!
            var cursorRight: UFix64 = self.nodes[cursor]?.right!

            if cursorRight != self.EMPTY {
                self.nodes[cursorRight]?.changeParent(parent: key)
            }

            if keyParent == self.EMPTY {
                self.root = cursor
            } else {
                key == self.nodes[keyParent]?.left!
                ? self.nodes[keyParent]?.changeLeft(left: cursor)
                : self.nodes[keyParent]?.changeRight(right: cursor)
            }

            self.nodes[cursor]?.changeParent(parent: keyParent)
            self.nodes[cursor]?.changeRight(right: key)

            self.nodes[key]?.changeParent(parent: cursor)
            self.nodes[key]?.changeLeft(left: cursorRight)

        }

        priv fun _replaceParent(a: UFix64, b: UFix64) {
            var bParent: UFix64 = self.nodes[b]?.parent!
            
            self.nodes[a]?.changeParent(parent: bParent)

            if bParent == self.EMPTY {
                self.root = a
            } else {
                b == self.nodes[bParent]?.left!
                ? self.nodes[bParent]?.changeLeft(left: a)
                : self.nodes[bParent]?.changeRight(right: a)
            }
        }

        pub fun _insertFixup(key: UFix64) {
            var _key: UFix64 = key
            var cursor: UFix64 = self.EMPTY
            while _key != self.root  && self.nodes[self.nodes[_key]?.parent!]?.red! {
                var keyParent: UFix64 = self.nodes[_key]?.parent!
                var keyGrandparent: UFix64 = self.nodes[keyParent]?.parent!

                if keyParent == self.nodes[keyGrandparent]?.left {
                    cursor = self.nodes[keyGrandparent]?.right!
                    if self.nodes[cursor]?.red! {
                        self.nodes[keyParent]?.changeColor(red: false)
                        self.nodes[cursor]?.changeColor(red: false)
                        self.nodes[keyGrandparent]?.changeColor(red: true)
                        _key = keyGrandparent
                    } else {
                        if _key == self.nodes[keyParent]?.right {
                            _key = keyParent
                            self._rotateLeft(key: _key)
                        }
                        keyParent = self.nodes[_key]?.parent!
                        self.nodes[keyParent]?.changeColor(red: false)
                        self.nodes[keyGrandparent]?.changeColor(red: true)
                        self._rotateRight(key: keyGrandparent)
                    }
                } else {
                    cursor = self.nodes[keyGrandparent]?.left!
                    if self.nodes[cursor]?.red! {
                        self.nodes[keyParent]?.changeColor(red: false)
                        self.nodes[cursor]?.changeColor(red: false)
                        self.nodes[keyGrandparent]?.changeColor(red: true)
                        _key = keyGrandparent
                    } else {
                        if _key == self.nodes[keyParent]?.left {
                            _key = keyParent
                            self._rotateRight(key: _key)
                        }
                        keyParent = self.nodes[_key]?.parent!
                        self.nodes[keyParent]?.changeColor(red: false)
                        self.nodes[keyGrandparent]?.changeColor(red: true)
                        self._rotateLeft(key: keyGrandparent)
                    }
                }
            }
            self.nodes[self.root]?.changeColor(red: false)
        }

        pub fun _removeFixup(key: UFix64) {
            log(key)
            var _key: UFix64 = key
            var cursor: UFix64 = self.EMPTY
            while _key != self.root && !self.nodes[_key]?.red! {
                var keyParent: UFix64 = self.nodes[_key]?.parent!

                if _key == self.nodes[keyParent]?.left {
                    cursor = self.nodes[keyParent]?.right!

                    if self.nodes[cursor]?.red! {
                        self.nodes[cursor]?.changeColor(red: false)
                        self.nodes[keyParent]?.changeColor(red: true)

                        self._rotateLeft(key: keyParent)
                        cursor = self.nodes[keyParent]?.right!
                    }

                    if (!self.nodes[self.nodes[cursor]?.left!]?.red! && !self.nodes[self.nodes[cursor]?.right!]?.red!) {
                        self.nodes[cursor]?.changeColor(red: true)
                        _key = keyParent
                    } else {
                        if !self.nodes[self.nodes[cursor]?.right!]?.red! {
                            self.nodes[self.nodes[cursor]?.left!]?.changeColor(red: false)
                            self.nodes[cursor]?.changeColor(red: true)

                            self._rotateRight(key: cursor)
                            cursor = self.nodes[keyParent]?.right!
                        }
                        self.nodes[cursor]?.changeColor(red: self.nodes[keyParent]?.red!)
                        self.nodes[keyParent]?.changeColor(red: false)
                        self.nodes[self.nodes[cursor]?.right!]?.changeColor(red: false)

                        self._rotateLeft(key: keyParent)
                        _key = self.root
                    }

                } else {
                    cursor = self.nodes[keyParent]?.left!
                    if self.nodes[cursor]?.red! {
                        self.nodes[cursor]?.changeColor(red: false)
                        self.nodes[keyParent]?.changeColor(red: true)
                        self._rotateRight(key: keyParent)
                        cursor = self.nodes[keyParent]?.left!
                    }
                    if !self.nodes[self.nodes[cursor]?.left!]?.red! && !self.nodes[self.nodes[cursor]?.right!]?.red! {
                        self.nodes[cursor]?.changeColor(red: true)
                        _key = keyParent
                    } else {
                        if !self.nodes[self.nodes[cursor]?.left!]?.red! {
                            self.nodes[self.nodes[cursor]?.right!]?.changeColor(red: false)
                            self.nodes[cursor]?.changeColor(red: true)

                            self._rotateLeft(key: cursor)
                            cursor = self.nodes[keyParent]?.left!
                        }
                        self.nodes[cursor]?.changeColor(red: self.nodes[keyParent]?.red!)
                        self.nodes[keyParent]?.changeColor(red: false)
                        self.nodes[self.nodes[cursor]?.left!]?.changeColor(red: false)

                        self._rotateRight(key: keyParent)
                        _key = self.root
                    }
                }
            }
            self.nodes[key]?.changeColor(red: false)
        }
    }
}
 