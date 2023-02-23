import * as fcl from "@onflow/fcl";

export default async function getDepositedAmount(address) {
    return fcl.query({
        cadence: USER_DEPOSITED,
        args: (arg, t) => [
            arg(address, t.Address),
        ],
    });
}

const USER_DEPOSITED = `
import OrderBookV18 from 0xOrderBookV18

pub fun main(userAddress: Address) : {String: UFix64} {
    let admin = getAccount(userAddress).getCapability(OrderBookV18.AdminPublicPath)!.borrow<&OrderBookV18.Admin{OrderBookV18.AdminPublic}>()!

    return {"Flow": admin.flowDeposited(), "FUSD": admin.fusdDeposited()}
}
`
