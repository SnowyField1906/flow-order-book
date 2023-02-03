import path from "path"
import { init, emulator, deployContractByName, getContractAddress } from "@onflow/flow-js-testing";

async function deployContract(param) {
    const [result, error] = await deployContractByName(param);
    if (error != null) {
        console.log(`Error in deployment - ${error}`);
        emulator.stop();
        process.exit(1);
    }
}

describe("Deployment", () => {
    let serviceAccount;
    let name = "SimpleMarket"

    beforeEach(async () => {
        const basePath = path.resolve(__dirname, "./../../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });
    });

    test("Should deploy contract", async () => {

        await deployContract({ to: serviceAccount, name: name })
        const SimpleMarket = await getContractAddress(name)
        expect(SimpleMarket).toBeDefined()
    });

    afterEach(async () => {
        await emulator.stop()
    })
})