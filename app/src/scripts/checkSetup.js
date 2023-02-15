import * as fcl from "@onflow/fcl";

export default async function checkSetup(address) {
    return fcl.query({
        cadence: CHECK_SETUP(address),
    });
}

const CHECK_SETUP = (address) => `
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main(): Bool {
    let signer = getAuthAccount(${address})
    return signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) != nil && signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) != nil
}
`