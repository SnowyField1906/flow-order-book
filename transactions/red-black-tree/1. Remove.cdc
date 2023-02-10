import RedBlackTree from "./../../contracts/RedBlackTree.cdc"

transaction(key: UInt32) {
    var acct: Address
    prepare(acct: AuthAccount) {
        self.acct = acct.address
    }

    execute {
        RedBlackTree.remove(key: key)
    }
}
 