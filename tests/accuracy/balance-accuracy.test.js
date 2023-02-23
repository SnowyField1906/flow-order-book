import path from "path"
import { init, emulator, deployContractByName, getAccountAddress, getContractAddress, getTransactionCode, sendTransaction, shallPass, executeScript, shallResolve, getScriptCode } from "@onflow/flow-js-testing";

import { addressMap, contractNames, transactionNames, scriptNames } from "../helpers.js"

const deployContract = async (param) => {
    const [, error] = await deployContractByName(param);
    if (error != null) {
        console.log(`Error in deployment - ${error}`);
        emulator.stop();
        process.exit(1);
    }
}

const scriptTemplate = async (name) => {
    return await getScriptCode({
        name: name,
        addressMap: addressMap
    })
}
const transactionTemplate = async (name) => {
    return await getTransactionCode({
        name: name,
        addressMap: addressMap
    })
}

describe("Offers & IDs", () => {
    const signers = Object.values(addressMap)

    beforeAll(async () => {
        const basePath = path.resolve(__dirname, "./../../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });

        await deployContract({ name: "interfaces/FungibleToken" })
        await deployContract({ name: "tokens/FUSD" })
        // await deployContract({ name: "tokens/FlowToken" })
        await deployContract({ name: "OrderBookVaultV12" })
        await deployContract({ name: "OrderBookV21" })

        await shallPass(
            sendTransaction({
                "code": await transactionTemplate("0. Setup Account"),
                "signers": signers,
                "args": []
            })
        )
    });

    test(`Should return offers and IDs`, async () => {
        console.log(await transactionTemplate("1. Limit Order"))
        await shallPass(
            sendTransaction({
                "code": await transactionTemplate("1. Limit Order"),
                "signers": signers,
                "args": ['40', '1', 'true']
            })
        )


    });


    afterAll(async () => {
        await emulator.stop()
    })
})
