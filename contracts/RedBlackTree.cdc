//LICENSE TO: https://github.com/perpdex/BokkyPooBahsRedBlackTreeLibrary/blob/feature/bulk/contracts/BokkyPooBahsRedBlackTreeLibrary.sol

access(all) contract RedBlackTree {
    priv var EMPTY: UInt32

    pub(set) var root: UInt32
    pub(set) var nodes: {UInt32: Node}
        
    init() {
        self.EMPTY = 0
        self.root = self.EMPTY
        self.nodes = {0 : Node(parent: 0, left: 0, right: 0, red: false)}
    }

    pub struct Node {
        pub var parent: UInt32
        pub var left:   UInt32
        pub var right:  UInt32
        pub var red:  Bool

        init(parent: UInt32, left: UInt32, right: UInt32, red: Bool) {
            self.parent = parent
            self.left = left
            self.right = right
            self.red = red
        }

        pub fun changeParent(parent: UInt32) {
            self.parent = parent
        }

        pub fun changeLeft(left: UInt32) {
            self.left = left
        }

        pub fun changeRight(right: UInt32) {
            self.right = right
        }

        pub fun changeColor(red: Bool) {
            self.red = red
        }
    }


    ////


    pub fun first(): UInt32 {
        var key: UInt32 = self.root
        if key != self.EMPTY {
            key = self.treeMinimum(key: key)
        }
        return key
    }

    pub fun last(): UInt32 {
        var key: UInt32 = self.root
        if key != self.EMPTY {
            key = self.treeMaximum(key: key)
        }
        return key
    }

    pub fun next(target: UInt32): UInt32 {
        assert(target != self.EMPTY, message: "Target is empty")
        if self.nodes[target]!.right != self.EMPTY {
            return self.treeMinimum(key: self.nodes[target]!.right)
        } else {
            var cursor: UInt32 = self.nodes[target]!.parent
            var _target: UInt32 = target
            while cursor != self.EMPTY && _target == self.nodes[cursor]!.right {
                _target = cursor
                cursor = self.nodes[cursor]!.parent
            }
            return cursor
        }
    }

    pub fun prev(target: UInt32): UInt32 {
        assert(target != self.EMPTY, message: "Target is empty")
        if self.nodes[target]!.left != self.EMPTY {
            return self.treeMaximum(key: self.nodes[target]!.left)
        } else {
            var cursor: UInt32 = self.nodes[target]!.parent
            var _target: UInt32 = target
            while cursor != self.EMPTY && _target == self.nodes[cursor]!.left {
                _target = cursor
                cursor = self.nodes[cursor]!.parent
            }
            return cursor
        }
    }

    pub fun exists(key: UInt32): Bool {
        return (key != self.EMPTY && self.nodes[key] != nil)
    }


    ////  


    pub fun insert(key: UInt32) {
        assert(key != self.EMPTY, message: "Key is empty")
        assert(!self.exists(key: key), message: "Key already exists")

        var cursor: UInt32 = self.EMPTY
        var probe: UInt32 = self.root

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


    pub fun remove(key: UInt32) {
        assert(key != self.EMPTY, message: "Key is empty")
        assert(self.exists(key: key), message: "Key does not exist")

        var cursor: UInt32 = key
        var probe: UInt32 = self.EMPTY

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

        var yParent: UInt32 = self.nodes[cursor]?.parent!
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


    pub fun treeMinimum(key: UInt32): UInt32 {
        var _key = key

        while self.nodes[_key]!.left != self.EMPTY {
            _key = self.nodes[_key]!.left
        }

        return _key
    }


    pub fun treeMaximum(key: UInt32): UInt32 {
        var _key = key

        while self.nodes[_key]!.right != self.EMPTY {
            _key = self.nodes[_key]!.right
        }

        return key
    }



    priv fun _rotateLeft(key: UInt32) {
        var cursor: UInt32 = self.nodes[key]?.right!
        var keyParent: UInt32 = self.nodes[key]?.parent!
        var cursorLeft: UInt32 = self.nodes[cursor]?.left!
        
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

    priv fun _rotateRight(key: UInt32) {
        var cursor: UInt32 = self.nodes[key]?.left!
        var keyParent: UInt32 = self.nodes[key]?.parent!
        var cursorRight: UInt32 = self.nodes[cursor]?.right!

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

    priv fun _replaceParent(a: UInt32, b: UInt32) {
        var bParent: UInt32 = self.nodes[b]?.parent!
        
        self.nodes[a]?.changeParent(parent: bParent)

        if bParent == self.EMPTY {
            self.root = a
        } else {
            b == self.nodes[bParent]?.left!
            ? self.nodes[bParent]?.changeLeft(left: a)
            : self.nodes[bParent]?.changeRight(right: a)
        }
    }

    pub fun _insertFixup(key: UInt32) {
        var _key: UInt32 = key
        var cursor: UInt32 = self.EMPTY
        while _key != self.root  && self.nodes[self.nodes[_key]?.parent!]?.red! {
            var keyParent: UInt32 = self.nodes[_key]?.parent!
            var keyGrandparent: UInt32 = self.nodes[keyParent]?.parent!

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

    pub fun _removeFixup(key: UInt32) {
        log(key)
        var _key: UInt32 = key
        var cursor: UInt32 = self.EMPTY
        while _key != self.root && !self.nodes[_key]?.red! {
            var keyParent: UInt32 = self.nodes[_key]?.parent!

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
 