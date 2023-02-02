import SimpleMarketv3 from 0x05
// import BinarySearchOffers from 0x9d380238fdd484d7

pub fun main(): [UInt32] {
    let ids: [UInt32] = []

    fun inorderTraversal(_ root: SimpleMarketv3.Node) {
        log(root)
        if root.left != nil {
            log(root.left)
            inorderTraversal(root.left!)
        }
        ids.append(root.key)
        if root.right != nil {
            log(root.right)
            inorderTraversal(root.right!)
        }
    }

    inorderTraversal(SimpleMarketv3.current!)

    return ids
}