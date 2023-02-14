import OrderBookV6 from "./../contracts/OrderBookV6.cdc"
import Token0 from "./../contracts/OrderBookV6.cdc"
import Token1 from "./../contracts/OrderBookV6.cdc"

transaction {
    prepare(acct: AuthAccount) {
        let newUser <- OrderBookV6.createUser()
        acct.save<@OrderBookV6.User>(<-newUser, to: /storage/User)

        let capability = acct.link<&OrderBookV6.User>(/public/User, target: /storage/User)
        let userRef = capability!.borrow()


        let vault0 <- Token0.createEmptyVault()
		acct.save<@Token0.Vault>(<-vault0, to: /storage/Vault0)
		let ReceiverRef0 = acct.link<&Token0.Vault{Token0.Receiver, Token0.Balance}>(/public/Receiver0, target: /storage/Vault0)

        let vault1 <- Token1.createEmptyVault()
		acct.save<@Token1.Vault>(<-vault1, to: /storage/Vault1)
		let ReceiverRef1 = acct.link<&Token1.Vault{Token1.Receiver, Token1.Balance}>(/public/Receiver1, target: /storage/Vault1)
    }

    execute {
        log("Capability and Link created")
    }
}