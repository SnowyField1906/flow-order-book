import from 0x9d380238fdd484d7

pub contract BinarySearchOffers { 
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

        let offerRef: &Offer? = &offers[key] as &Offer?
        let rootRef: &Offer? = &offers[root.key] as &Offer?

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

        let offerRef: &Offer? = &offers[key] as &Offer?
        let rootRef: &Offer? = &offers[root.key] as &Offer?

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
 