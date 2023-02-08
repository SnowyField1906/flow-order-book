//LICENSE TO: https://github.com/perpdex/BokkyPooBahsRedBlackTreeLibrary

access(all) contract RedBlackTree {
    pub var EMPTY: UInt32

    pub(set) var root: UInt32
    pub(set) var nodes: {UInt32: Node}
        
    init() {
        self.EMPTY = 0
        self.root = self.EMPTY
        self.nodes = {}
    }


    pub struct Node {
        pub var parent: UInt32
        pub var left:   UInt32
        pub var right:  UInt32
        pub var red:  Bool

        init(parent: UInt32, left: UInt32, right: UInt32, red: Bool) {
            self.parent = RedBlackTree.EMPTY
            self.left = RedBlackTree.EMPTY
            self.right = RedBlackTree.EMPTY
            self.red = false
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
        var cursor: UInt32 = self.nodes[target]!.parent
        if self.nodes[cursor]!.right != self.EMPTY {
            cursor = self.treeMinimum(key: self.nodes[target]!.right)
        } else {
            var _target: UInt32 = target
            while cursor != self.EMPTY && _target == self.nodes[cursor]!.right {
                _target = cursor
                cursor = self.nodes[cursor]!.parent
            }
        }
        return cursor
    }

    pub fun prev(target: UInt32): UInt32 {
        assert(target != self.EMPTY, message: "Target is empty")
        var cursor: UInt32 = self.nodes[target]!.parent
        if self.nodes[cursor]!.left != self.EMPTY {
            cursor = self.treeMaximum(key: self.nodes[target]!.left)
        } else {
            var _target: UInt32 = target
            while cursor != self.EMPTY && _target == self.nodes[cursor]!.left {
                _target = cursor
                cursor = self.nodes[cursor]!.parent
            }
        }
        return cursor
    }

    pub fun exists(key: UInt32): Bool {
        return (
            key != self.EMPTY &&
            // (key == self.root || self.nodes[key]?.parent != self.EMPTY)
            self.nodes[key] != nil
        )
    }

    pub fun isEmpty(): Bool {
        return self.root == self.EMPTY
    }

    pub fun getNode(key: UInt32): Node {
        assert(
            self.exists(key: key),
            message: "Key does not exist"
        )
        return self.nodes[key]!
    }


    ////  


    pub fun insert(key: UInt32) {
        log("Starting to insert")

        assert(key != self.EMPTY, message: "Key is empty")
        assert(!self.exists(key: key), message: "Key already exists")

        var cursor: UInt32 = self.EMPTY
        var probe: UInt32 = self.root

        log("Starting to do while-loop")

        while probe != self.EMPTY {
            cursor = probe
            probe = key < probe
                ? self.nodes[probe]!.left
                : self.nodes[probe]!.right
        }

        log("Starting to re-assign node")

        self.nodes[key] = Node(
            parent: cursor,
            left: self.EMPTY,
            right: self.EMPTY,
            red: true
        );

        if key < cursor {
            self.nodes[cursor]?.changeLeft(left: key)
        } else {
            self.nodes[cursor]?.changeRight(right: key)
        }

        if cursor == self.EMPTY {
            self.root = key
        }

        log("Fixing up")
        self._insertFixup(key: key)

        log("Finishing to insert")
    }


    pub fun remove(key: UInt32) {
        assert(key != self.EMPTY, message: "Key is empty")
        assert(self.exists(key: key), message: "Key does not exist")

        var _key: UInt32 = key
        var cursor: UInt32 = _key
        var probe: UInt32 = self.EMPTY

        if self.nodes[key]!.left == self.EMPTY || self.nodes[key]!.right == self.EMPTY {
            cursor = _key
        } else {
            cursor = self.nodes[key]?.right!
            while (self.nodes[cursor]?.left != self.EMPTY) {
                cursor = self.nodes[cursor]?.left!
            }
        }

        if self.nodes[cursor]?.left != self.EMPTY {
            probe = self.nodes[cursor]?.left!
        } else {
            probe = self.nodes[cursor]?.right!
        }

        var yParent: UInt32 = self.nodes[cursor]?.parent!
        self.nodes[probe]?.changeParent(parent: yParent)

        if yParent != self.EMPTY {
            if cursor == self.nodes[yParent]?.left {
                self.nodes[yParent]?.changeLeft(left: probe)
            } else {
                self.nodes[yParent]?.changeRight(right: probe)
            }
        } else {
            self.root = probe
        }

        var doFixup: Bool = !self.nodes[cursor]?.red!

        if cursor != _key {
            self._replaceParent(a: cursor, b: _key)
            self.nodes[cursor]?.changeLeft(left: self.nodes[key]?.left!)
            self.nodes[self.nodes[cursor]?.left!]?.changeParent(parent: cursor)
            self.nodes[cursor]?.changeRight(right: self.nodes[key]?.right!)
            self.nodes[self.nodes[cursor]?.right!]?.changeParent(parent: cursor)
            self.nodes[cursor]?.changeColor(red: self.nodes[key]?.red!)
            cursor <-> _key
        }

        if doFixup {
            self._removeFixup(var: probe)
        }

        if probe == self.EMPTY {
            self.nodes[probe]?.changeParent(parent: self.EMPTY)
        }
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
        } else if key == self.nodes[keyParent]?.left! {
            self.nodes[keyParent]?.changeLeft(left: cursor)
        } else {
            self.nodes[keyParent]?.changeRight(right: cursor)
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
        } else if key == self.nodes[keyParent]?.right! {
            self.nodes[keyParent]?.changeRight(right: cursor)
        } else {
            self.nodes[keyParent]?.changeLeft(left: cursor)
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
        } else if b == self.nodes[bParent]?.left! {
            self.nodes[bParent]?.changeLeft(left: a)
        } else {
            self.nodes[bParent]?.changeRight(right: a)
        }
    }

    pub fun _insertFixup(key: UInt32) {
        log(self.nodes[key]?.parent)

        var _key: UInt32 = key
        var cursor: UInt32 = self.EMPTY
        while _key != self.root &&
            self.nodes[self.nodes[_key]?.parent!] != nil &&
            self.nodes[self.nodes[_key]?.parent!]?.red!
        {
            var keyParent: UInt32 = self.nodes[key]?.parent!
            if keyParent == self.nodes[self.nodes[keyParent]?.parent!]?.left {
                cursor = self.nodes[self.nodes[keyParent]?.parent!]?.right!
                if self.nodes[cursor]?.red! {
                    self.nodes[keyParent]?.changeColor(red: false)
                    self.nodes[cursor]?.changeColor(red: false)
                    self.nodes[self.nodes[keyParent]?.parent!]?.changeColor(red: true)
                    _key = self.nodes[keyParent]?.parent!
                } else {
                    if key == self.nodes[keyParent]?.right {
                        _key = keyParent
                        self._rotateLeft(key: key)
                    }
                    keyParent = self.nodes[key]?.parent!
                    self.nodes[keyParent]?.changeColor(red: false)
                    self.nodes[self.nodes[keyParent]?.parent!]?.changeColor(red: true)
                    self._rotateRight(key: self.nodes[keyParent]?.parent!)
                }
            } else {
                cursor = self.nodes[self.nodes[keyParent]?.parent!]?.left!
                if self.nodes[cursor]?.red! {
                    self.nodes[keyParent]?.changeColor(red: false)
                    self.nodes[cursor]?.changeColor(red: false)
                    self.nodes[self.nodes[keyParent]?.parent!]?.changeColor(red: true)
                    _key = self.nodes[keyParent]?.parent!
                } else {
                    if key == self.nodes[keyParent]?.left {
                        _key = keyParent
                        self._rotateRight(key: key)
                    }
                    keyParent = self.nodes[key]?.parent!
                    self.nodes[keyParent]?.changeColor(red: false)
                    self.nodes[self.nodes[keyParent]?.parent!]?.changeColor(red: true)
                    self._rotateLeft(key: self.nodes[keyParent]?.parent!)
                }
            }
        }
        self.nodes[self.root]?.changeColor(red: false)
    }

    pub fun _removeFixup(var key: UInt32) {
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

                if 
                    !self.nodes[self.nodes[cursor]?.left!]?.red! &&
                    !self.nodes[self.nodes[cursor]?.right!]?.red!
                {
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
                if 
                    !self.nodes[self.nodes[cursor]?.left!]?.red! &&
                    !self.nodes[self.nodes[cursor]?.right!]?.red!
                {
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
 