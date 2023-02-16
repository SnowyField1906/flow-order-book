import OrderBookV7 from 0x9d380238fdd484d7
import FlowToken from 0x7e60df042a9c0868
import SnowToken from 0x9d380238fdd484d7

transaction {
    prepare(acct: AuthAccount) {
        let capability = acct.link<&OrderBookV7.User>(/public/User, target: /storage/User)
        let userRef = capability!.borrow()


        let FlowVault <- FlowToken.createEmptyVault()
		acct.save<@FlowToken.Vault>(<-FlowVault, to: /storage/FlowVault)
		let ReceiverRef0 = acct.link<&FlowToken.Vault{FlowToken.Receiver, FlowToken.Balance}>(/public/Receiver0, target: /storage/Vault0)

        let SnowVault <- SnowToken.createEmptyVault()
		acct.save<@SnowToken.Vault>(<-SnowVault, to: /storage/SnowVault)
		let ReceiverRef1 = acct.link<&SnowToken.Vault{SnowToken.Receiver, SnowToken.Balance}>(/public/Receiver1, target: /storage/SnowVault)
    }

    execute {
        log("Capability and Link created")
    }
}