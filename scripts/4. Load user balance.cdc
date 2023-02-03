import Token0 from 0x02
import Token1 from 0x03

pub fun main(user: Address) : [UFix64] {
    let user = getAccount(user)

    let userRef0 = user.getCapability(/public/Receiver0)
                    .borrow<&Token0.Vault{Token0.Balance}>()
                    ?? panic("Could not borrow a reference to the receiver")
    let userRef1 = user.getCapability(/public/Receiver1)
                    .borrow<&Token1.Vault{Token1.Balance}>()
                    ?? panic("Could not borrow a reference to the receiver")

    return [userRef0.balance, userRef1.balance]
}