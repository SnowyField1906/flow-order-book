import SimpleMarket from 0x01

pub fun main(address: Address) : UFix64 {
    let user = getAccount(address)

    let userCapablity = user.getCapability<&SimpleMarket.User>(/public/User)
    
    let userReference = userCapablity.borrow()
        ?? panic("Could not borrow a reference to the User capability")
    
    return userReference.balance
}