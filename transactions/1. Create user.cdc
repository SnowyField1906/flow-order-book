import SimpleMarket from 0x01
import Token0 from 0x04
import Token1 from 0x05

transaction {
    prepare(acct: AuthAccount) {
        let newUser <- SimpleMarket.createUser()
        acct.save<@SimpleMarket.User>(<-newUser, to: /storage/User)

        let capability = acct.link<&SimpleMarket.User>(/public/User, target: /storage/User)
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