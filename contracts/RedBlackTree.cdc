pub contract RedBlackTree {
    pub var EMPTY: UInt32

    init() {
        self.EMPTY = 0
    }

    pub struct Node {
        pub var parent: UInt32
        pub var left:   UInt32
        pub var right:  UInt32
        pub var red:  Bool

        init(parent: UInt32, left: UInt32, right: UInt32, red: Bool) {
            self.parent = 0
            self.left = 0
            self.right = 0
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

    pub struct Tree {
        pub(set) var root: UInt32
        pub(set) var nodes: {UInt32: Node}
        
        init(root: UInt32, nodes: {UInt32: Node}) {
            self.root = 0
            self.nodes = {}
        }
    }


    ////


    pub fun first(tree: Tree): UInt32 {
        var key: UInt32 = tree.root
        if key != self.EMPTY {
            key = self.treeMinimum(tree: tree, key: key)
        }
        return key
    }

    pub fun last(tree: Tree): UInt32 {
        var key: UInt32 = tree.root
        if key != self.EMPTY {
            key = self.treeMaximum(tree: tree, key: key)
        }
        return key
    }

    pub fun next(tree: Tree, target: UInt32): UInt32 {
        assert(target != self.EMPTY, message: "Target is empty")
        var cursor: UInt32 = tree.nodes[target]!.parent
        if tree.nodes[cursor]!.right != self.EMPTY {
            cursor = self.treeMinimum(tree: tree, key: tree.nodes[target]!.right)
        } else {
            var _target: UInt32 = target
            while cursor != self.EMPTY && _target == tree.nodes[cursor]!.right {
                _target = cursor
                cursor = tree.nodes[cursor]!.parent
            }
        }
        return cursor
    }

    pub fun prev(tree: Tree, target: UInt32): UInt32 {
        assert(target != self.EMPTY, message: "Target is empty")
        var cursor: UInt32 = tree.nodes[target]!.parent
        if tree.nodes[cursor]!.left != self.EMPTY {
            cursor = self.treeMaximum(tree: tree, key: tree.nodes[target]!.left)
        } else {
            var _target: UInt32 = target
            while cursor != self.EMPTY && _target == tree.nodes[cursor]!.left {
                _target = cursor
                cursor = tree.nodes[cursor]!.parent
            }
        }
        return cursor
    }

    pub fun exists(tree: Tree, key: UInt32): Bool {
        return (
            key != self.EMPTY &&
            (key == tree.root || tree.nodes[key]!.parent != self.EMPTY)
        )
    }

    pub fun isEmpty(tree: Tree): Bool {
        return tree.root == self.EMPTY
    }

    pub fun getNode(tree: Tree, key: UInt32): Node {
        assert(
            self.exists(tree: tree, key: key),
            message: "Key does not exist"
        )
        return tree.nodes[key]!
    }


    ////  


    pub fun insert(
        tree: Tree,
        key: UInt32,
        aggregate: ((UInt32): Bool)
    ) {
        assert(key != self.EMPTY, message: "Key is empty")
        assert(!self.exists(tree: tree, key: key), message: "Key already exists")

        var cursor: UInt32 = self.EMPTY
        var probe: UInt32 = tree.root

        while probe != self.EMPTY {
            cursor = probe
            probe = key < probe
                ? tree.nodes[probe]!.left
                : tree.nodes[probe]!.right
        }

        if key < cursor {
            tree.nodes[cursor]?.changeLeft(left: key)
        } else {
            tree.nodes[cursor]?.changeRight(right: key)
        }

        if cursor == self.EMPTY {
            tree.root = key
        }

        self._aggregateRecursive(tree: tree, key: cursor, aggregate: aggregate)
        self._insertFixup(tree: tree, key: key, aggregate: aggregate)
    }


    pub fun remove(
        tree: Tree,
        key: UInt32,
        aggregate: ((UInt32): Bool)
    ) {
        assert(key != self.EMPTY, message: "Key is empty")
        assert(self.exists(tree: tree, key: key), message: "Key does not exist")

        var _key: UInt32 = key
        var cursor: UInt32 = _key
        var probe: UInt32 = self.EMPTY

        if tree.nodes[key]!.left == self.EMPTY || tree.nodes[key]!.right == self.EMPTY {
            cursor = _key
        } else {
            cursor = tree.nodes[key]?.right!
            while (tree.nodes[cursor]?.left != self.EMPTY) {
                cursor = tree.nodes[cursor]?.left!
            }
        }

        if tree.nodes[cursor]?.left != self.EMPTY {
            probe = tree.nodes[cursor]?.left!
        } else {
            probe = tree.nodes[cursor]?.right!
        }

        var yParent: UInt32 = tree.nodes[cursor]?.parent!
        tree.nodes[probe]?.changeParent(parent: yParent)

        if yParent != self.EMPTY {
            if cursor == tree.nodes[yParent]?.left {
                tree.nodes[yParent]?.changeLeft(left: probe)
            } else {
                tree.nodes[yParent]?.changeRight(right: probe)
            }
        } else {
            tree.root = probe
        }

        var doFixup: Bool = !tree.nodes[cursor]?.red!

        if cursor != _key {
            self._replaceParent(tree: tree, a: cursor, b: _key)
            tree.nodes[cursor]?.changeLeft(left: tree.nodes[key]?.left!)
            tree.nodes[tree.nodes[cursor]?.left!]?.changeParent(parent: cursor)
            tree.nodes[cursor]?.changeRight(right: tree.nodes[key]?.right!)
            tree.nodes[tree.nodes[cursor]?.right!]?.changeParent(parent: cursor)
            tree.nodes[cursor]?.changeColor(red: tree.nodes[key]?.red!)
            cursor <-> _key
            self._aggregateRecursive(tree: tree, key: _key, aggregate: aggregate)
        }

        if doFixup {
            self._removeFixup(tree: tree, var: probe, aggregate: aggregate)
        }

        self._aggregateRecursive(tree: tree, key: yParent, aggregate: aggregate)

        if probe == self.EMPTY {
            tree.nodes[probe]?.changeParent(parent: self.EMPTY)
        }
    }


    ////


    pub fun treeMinimum(tree: Tree, key: UInt32): UInt32 {
        var _key = key

        while tree.nodes[_key]!.left != self.EMPTY {
            _key = tree.nodes[_key]!.left
        }

        return _key
    }


    pub fun treeMaximum(tree: Tree, key: UInt32): UInt32 {
        var _key = key

        while tree.nodes[_key]!.right != self.EMPTY {
            _key = tree.nodes[_key]!.right
        }

        return key
    }



    priv fun _rotateLeft(
        tree: Tree,
        key: UInt32,
        aggregate: ((UInt32): Bool)
    ) {
        var cursor: UInt32 = tree.nodes[key]?.right!
        var keyParent: UInt32 = tree.nodes[key]?.parent!
        var cursorLeft: UInt32 = tree.nodes[cursor]?.left!
        
        if cursorLeft != self.EMPTY {
            tree.nodes[cursorLeft]?.changeParent(parent: key)
        }

        if keyParent == self.EMPTY {
            tree.root = cursor
        } else if key == tree.nodes[keyParent]?.left! {
            tree.nodes[keyParent]?.changeLeft(left: cursor)
        } else {
            tree.nodes[keyParent]?.changeRight(right: cursor)
        }

        tree.nodes[cursor]?.changeParent(parent: keyParent)
        tree.nodes[cursor]?.changeLeft(left: key)
        
        tree.nodes[key]?.changeParent(parent: cursor)
        tree.nodes[key]?.changeRight(right: cursorLeft)

        aggregate(key)
        aggregate(cursor)
    }

    priv fun _rotateRight(
        tree: Tree,
        key: UInt32,
        aggregate: ((UInt32): Bool)
    ) {
        var cursor: UInt32 = tree.nodes[key]?.left!
        var keyParent: UInt32 = tree.nodes[key]?.parent!
        var cursorRight: UInt32 = tree.nodes[cursor]?.right!

        if cursorRight != self.EMPTY {
            tree.nodes[cursorRight]?.changeParent(parent: key)
        }

        if keyParent == self.EMPTY {
            tree.root = cursor
        } else if key == tree.nodes[keyParent]?.right! {
            tree.nodes[keyParent]?.changeRight(right: cursor)
        } else {
            tree.nodes[keyParent]?.changeLeft(left: cursor)
        }

        tree.nodes[cursor]?.changeParent(parent: keyParent)
        tree.nodes[cursor]?.changeRight(right: key)

        tree.nodes[key]?.changeParent(parent: cursor)
        tree.nodes[key]?.changeLeft(left: cursorRight)

        aggregate(key)
        aggregate(cursor)
    }

    priv fun _replaceParent(
        tree: Tree,
        a: UInt32,
        b: UInt32
    ) {
        var bParent: UInt32 = tree.nodes[b]?.parent!
        
        tree.nodes[a]?.changeParent(parent: bParent)

        if bParent == self.EMPTY {
            tree.root = a
        } else if b == tree.nodes[bParent]?.left! {
            tree.nodes[bParent]?.changeLeft(left: a)
        } else {
            tree.nodes[bParent]?.changeRight(right: a)
        }
    }

    priv fun _aggregateRecursive(
        tree: Tree,
        key: UInt32,
        aggregate: ((UInt32): Bool)
    ) {
        var stopped: Bool = true
        var _key: UInt32 = key

        while (key != self.EMPTY) {
            if !stopped {
                stopped = aggregate(key)
            }
            _key = tree.nodes[key]?.parent!
        }
    }

    pub fun _insertFixup(
        tree: Tree,
        key: UInt32,
        aggregate: ((UInt32): Bool)
    ) {
        var _key: UInt32 = key
        var cursor: UInt32 = self.EMPTY
        while _key != tree.root &&
            tree.nodes[tree.nodes[_key]?.parent!]?.red!
        {
            var keyParent: UInt32 = tree.nodes[key]?.parent!
            if keyParent == tree.nodes[tree.nodes[keyParent]?.parent!]?.left {
                cursor = tree.nodes[tree.nodes[keyParent]?.parent!]?.right!
                if tree.nodes[cursor]?.red! {
                    tree.nodes[keyParent]?.changeColor(red: false)
                    tree.nodes[cursor]?.changeColor(red: false)
                    tree.nodes[tree.nodes[keyParent]?.parent!]?.changeColor(red: true)
                    _key = tree.nodes[keyParent]?.parent!
                } else {
                    if key == tree.nodes[keyParent]?.right {
                        _key = keyParent
                        self._rotateLeft(tree: tree, key: key, aggregate: aggregate)
                    }
                    keyParent = tree.nodes[key]?.parent!
                    tree.nodes[keyParent]?.changeColor(red: false)
                    tree.nodes[tree.nodes[keyParent]?.parent!]?.changeColor(red: true)
                    self._rotateRight(tree: tree, key: tree.nodes[keyParent]?.parent!, aggregate: aggregate)
                }
            } else {
                cursor = tree.nodes[tree.nodes[keyParent]?.parent!]?.left!
                if tree.nodes[cursor]?.red! {
                    tree.nodes[keyParent]?.changeColor(red: false)
                    tree.nodes[cursor]?.changeColor(red: false)
                    tree.nodes[tree.nodes[keyParent]?.parent!]?.changeColor(red: true)
                    _key = tree.nodes[keyParent]?.parent!
                } else {
                    if key == tree.nodes[keyParent]?.left {
                        _key = keyParent
                        self._rotateRight(tree: tree, key: key, aggregate: aggregate)
                    }
                    keyParent = tree.nodes[key]?.parent!
                    tree.nodes[keyParent]?.changeColor(red: false)
                    tree.nodes[tree.nodes[keyParent]?.parent!]?.changeColor(red: true)
                    self._rotateLeft(tree: tree, key: tree.nodes[keyParent]?.parent!, aggregate: aggregate)
                }
            }
        }
        tree.nodes[tree.root]?.changeColor(red: false)
    }

    pub fun _removeFixup(
        tree: Tree,
        var key: UInt32,
        aggregate: ((UInt32): Bool)
    ) {
        var _key: UInt32 = key
        var cursor: UInt32 = self.EMPTY

        while _key != tree.root && !tree.nodes[_key]?.red! {
            var keyParent: UInt32 = tree.nodes[_key]?.parent!

            if _key == tree.nodes[keyParent]?.left {
                cursor = tree.nodes[keyParent]?.right!

                if tree.nodes[cursor]?.red! {
                    tree.nodes[cursor]?.changeColor(red: false)
                    tree.nodes[keyParent]?.changeColor(red: true)

                    self._rotateLeft(tree: tree, key: keyParent, aggregate: aggregate)
                    cursor = tree.nodes[keyParent]?.right!
                }

                if 
                    !tree.nodes[tree.nodes[cursor]?.left!]?.red! &&
                    !tree.nodes[tree.nodes[cursor]?.right!]?.red!
                {
                    tree.nodes[cursor]?.changeColor(red: true)
                    _key = keyParent
                } else {
                    if !tree.nodes[tree.nodes[cursor]?.right!]?.red! {
                        tree.nodes[tree.nodes[cursor]?.left!]?.changeColor(red: false)
                        tree.nodes[cursor]?.changeColor(red: true)

                        self._rotateRight(tree: tree, key: cursor, aggregate: aggregate)
                        cursor = tree.nodes[keyParent]?.right!
                    }
                    tree.nodes[cursor]?.changeColor(red: tree.nodes[keyParent]?.red!)
                    tree.nodes[keyParent]?.changeColor(red: false)
                    tree.nodes[tree.nodes[cursor]?.right!]?.changeColor(red: false)

                    self._rotateLeft(tree: tree, key: keyParent, aggregate: aggregate)
                    _key = tree.root
                }

            } else {
                cursor = tree.nodes[keyParent]?.left!
                if tree.nodes[cursor]?.red! {
                    tree.nodes[cursor]?.changeColor(red: false)
                    tree.nodes[keyParent]?.changeColor(red: true)
                    self._rotateRight(tree: tree, key: keyParent, aggregate: aggregate)
                    cursor = tree.nodes[keyParent]?.left!
                }
                if 
                    !tree.nodes[tree.nodes[cursor]?.left!]?.red! &&
                    !tree.nodes[tree.nodes[cursor]?.right!]?.red!
                {
                    tree.nodes[cursor]?.changeColor(red: true)
                    _key = keyParent
                } else {
                    if !tree.nodes[tree.nodes[cursor]?.left!]?.red! {
                        tree.nodes[tree.nodes[cursor]?.right!]?.changeColor(red: false)
                        tree.nodes[cursor]?.changeColor(red: true)

                        self._rotateLeft(tree: tree, key: cursor, aggregate: aggregate)
                        cursor = tree.nodes[keyParent]?.left!
                    }
                    tree.nodes[cursor]?.changeColor(red: tree.nodes[keyParent]?.red!)
                    tree.nodes[keyParent]?.changeColor(red: false)
                    tree.nodes[tree.nodes[cursor]?.left!]?.changeColor(red: false)

                    self._rotateRight(tree: tree, key: keyParent, aggregate: aggregate)
                    _key = tree.root
                }
            }
        }
        tree.nodes[key]?.changeColor(red: false)
    }


    ////


    // pub struct JoinParams {
    //     var left: UInt32
    //     var key: UInt32
    //     var right: UInt32
    //     var leftBlackHeight: Uint8
    //     var rightBlackHeight: Uint8

    //     init(
    //         left: UInt32,
    //         key: UInt32,
    //         right: UInt32,
    //         leftBlackHeight: Uint8,
    //         rightBlackHeight: Uint8
    //     ) {
    //         self.left = left
    //         self.key = key
    //         self.right = right
    //         self.leftBlackHeight = leftBlackHeight
    //         self.rightBlackHeight = rightBlackHeight
    //     }
    // }

    // pub fun joinRight(
    //     tree: Tree,
    //     params: JoinParams,
    //     aggregate: ((UInt32): Bool)
    // ) {
    //     if
    //         !tree.nodes[params.left].red &&
    //         params.leftBlackHeight == params.rightBlackHeight
    //     {
    //         tree.nodes[params.key].red = true;
    //         tree.nodes[params.key].left = params.left;
    //         tree.nodes[params.key].right = params.right;
    //         aggregate(params.key);
    //         return params;
    //     }

    //     var tParams: JoinParams = joinRight(
    //         tree,
    //         JoinParams(
    //             left: tree.nodes[params.left].right,
    //             key: params.key,
    //             right: params.right,
    //             leftBlackHeight: params.leftBlackHeight -
    //                 (tree.nodes[params.left].red ? 0 : 1),
    //             rightBlackHeight: params.rightBlackHeight
    //         ),
    //         aggregate
    //     );
    //     tree.nodes[params.left].right = t;
    //     tree.nodes[params.left].parent = EMPTY;
    //     aggregate(params.left);

    //     if (
    //         !tree.nodes[params.left].red &&
    //         tree.nodes[t].red &&
    //         tree.nodes[tree.nodes[t].right].red
    //     ) {
    //         tree.nodes[tree.nodes[t].right].red = false;
    //         rotateLeft(tree, params.left, aggregate);
    //         return (t, params.leftBlackHeight);
    //     }
    //     return (params.left, params.leftBlackHeight);
    // }

    // struct JoinLeftCallStack {
    //     uint80 right;
    // }

    // function joinLeft(
    //     Tree storage tree,
    //     JoinParams memory params,
    //     function(uint80) returns (bool) aggregate
    // ) internal returns (uint80 resultKey) {

    //     if (
    //         !tree.nodes[params.right].red &&
    //         params.leftBlackHeight == params.rightBlackHeight
    //     ) {
    //         tree.nodes[params.key].red = true;
    //         tree.nodes[params.key].left = params.left;
    //         tree.nodes[params.key].right = params.right;
    //         if (params.left != EMPTY) {
    //             tree.nodes[params.left].parent = params.key;
    //         }
    //         if (params.right != EMPTY) {
    //             tree.nodes[params.right].parent = params.key;
    //         }
    //         aggregate(params.key);
    //         return params.key;
    //     }

    //     uint80 t = joinLeft(
    //         tree,
    //         JoinParams({
    //             left: params.left,
    //             key: params.key,
    //             right: tree.nodes[params.right].left,
    //             leftBlackHeight: params.leftBlackHeight,
    //             rightBlackHeight: params.rightBlackHeight -
    //                 (tree.nodes[params.right].red ? 0 : 1)
    //         }),
    //         aggregate
    //     );
    //     tree.nodes[params.right].left = t;
    //     tree.nodes[params.right].parent = EMPTY;
    //     if (t != EMPTY) {
    //         tree.nodes[t].parent = params.right;
    //     }
    //     aggregate(params.right);

    //     if (
    //         !tree.nodes[params.right].red &&
    //         tree.nodes[t].red &&
    //         tree.nodes[tree.nodes[t].left].red
    //     ) {
    //         tree.nodes[tree.nodes[t].left].red = false;
    //         rotateRight(tree, params.right, aggregate);
    //         return t;
    //     }
    //     return params.right;
    // }

    // function join(
    //     Tree storage tree,
    //     uint80 left,
    //     uint80 key,
    //     uint80 right,
    //     function(uint80) returns (bool) aggregate,
    //     uint8 leftBlackHeight,
    //     uint8 rightBlackHeight
    // ) private returns (uint80 t, uint8 tBlackHeight) {
    //     if (leftBlackHeight > rightBlackHeight) {
    //         (t, tBlackHeight) = joinRight(
    //             tree,
    //             JoinParams({
    //                 left: left,
    //                 key: key,
    //                 right: right,
    //                 leftBlackHeight: leftBlackHeight,
    //                 rightBlackHeight: rightBlackHeight
    //             }),
    //             aggregate
    //         );
    //         tBlackHeight = leftBlackHeight;
    //         if (tree.nodes[t].red && tree.nodes[tree.nodes[t].right].red) {
    //             tree.nodes[t].red = false;
    //             tBlackHeight += 1;
    //         }
    //     } else if (leftBlackHeight < rightBlackHeight) {
    //         t = joinLeft(
    //             tree,
    //             JoinParams({
    //                 left: left,
    //                 key: key,
    //                 right: right,
    //                 leftBlackHeight: leftBlackHeight,
    //                 rightBlackHeight: rightBlackHeight
    //             }),
    //             aggregate
    //         );
    //         tBlackHeight = rightBlackHeight;
    //         if (tree.nodes[t].red && tree.nodes[tree.nodes[t].left].red) {
    //             tree.nodes[t].red = false;
    //             tBlackHeight += 1;
    //         }
    //     } else {
    //         bool red = !tree.nodes[left].red && !tree.nodes[right].red;
    //         tree.nodes[key].red = red;
    //         tree.nodes[key].left = left;
    //         tree.nodes[key].right = right;
    //         aggregate(key);
    //         (t, tBlackHeight) = (key, leftBlackHeight + (red ? 0 : 1));
    //     }
    // }

    // struct SplitRightCallStack {
    //     uint80 t;
    //     uint8 childBlackHeight;
    // }

    // function splitRight(
    //     Tree storage tree,
    //     uint80 t,
    //     uint80 key,
    //     function(uint80, uint80) returns (bool) lessThan,
    //     function(uint80) returns (bool) aggregate,
    //     uint8 blackHeight
    // ) private returns (uint80 resultKey, uint8 resultBlackHeight) {
    //     if (t == EMPTY) return (EMPTY, blackHeight);
    //     uint8 childBlackHeight = blackHeight - (tree.nodes[t].red ? 0 : 1);
    //     if (key == t) return (tree.nodes[t].right, childBlackHeight);
    //     if (lessThan(key, t)) {
    //         (uint80 r, uint8 rBlackHeight) = splitRight(
    //             tree,
    //             tree.nodes[t].left,
    //             key,
    //             lessThan,
    //             aggregate,
    //             childBlackHeight
    //         );        }
    //         return
    //             join(
    //                 tree,
    //                 r,
    //                 t,
    //                 tree.nodes[t].right,
    //                 aggregate,
    //                 rBlackHeight,
    //                 childBlackHeight
    //             );
    //     } else {
    //         return
    //             splitRight(
    //                 tree,
    //                 tree.nodes[t].right,
    //                 key,
    //                 lessThan,
    //                 aggregate,
    //                 childBlackHeight
    //             );
    //     }
    // }

}
 