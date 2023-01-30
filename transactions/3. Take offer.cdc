import SimpleMarket from 0x01
import Token0 from 0x02
import Token1 from 0x03


transaction(_ id: UFix64) {

    let userRef: &SimpleMarket.User
    let vaultRef0: &Token0.Vault
    let vaultRef1: &Token1.Vault

    prepare(acct: AuthAccount) {
    
        self.userRef = acct.borrow<&SimpleMarket.User>(from: /storage/User)
        ?? panic("Could not borrow user reference")


        self.vaultRef0 = acct.borrow<&BasicToken.Vault>(from: /storage/Vault0)
        ?? panic("Could not borrow a reference to the owner's vault")


    }

    execute {
        let temporaryVault <- vaultRef0.withdraw(amount: 10.0)
        vaultRef0.deposit(from: <-temporaryVault)

        SimpleMarket.take(id)
    }
}