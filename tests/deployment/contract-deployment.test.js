import path from "path"
import { init, emulator, deployContractByName, getContractAddress } from "@onflow/flow-js-testing";

import { addressMap, contractNames } from "../helpers.js"

async function deployContract(param) {
    const [, error] = await deployContractByName(param);
    if (error != null) {
        console.log(`Error in deployment - ${error}`);
        emulator.stop();
        process.exit(1);
    }
}

describe("Deployment", () => {
    beforeEach(async () => {
        const basePath = path.resolve(__dirname, "./../../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });
    });

    test("Should deploy contract", async () => {
        await deployContract({ name: contractNames[0] })
        const OrderBookV16 = await getContractAddress(contractNames[0])
        expect(OrderBookV16).toBeDefined()
    });

    afterEach(async () => {
        await emulator.stop()
    })
})