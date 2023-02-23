import OrderBookV18 from 0xOrderBookV18

pub fun main(userAddress: Address) : {String: UFix64} {
    let admin = getAccount(userAddress).getCapability(OrderBookV18.AdminPublicPath)!.borrow<&OrderBookV18.Admin{OrderBookV18.AdminPublic}>()!

    return {"Flow": admin.flowDeposited(), "FUSD": admin.fusdDeposited()}
}