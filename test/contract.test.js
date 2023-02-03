import path from "path"
import { init, emulator, getAccountAddress, deployContractByName, getContractAddress, getContractCode, getTransactionCode, sendTransaction, shallPass } from "@onflow/flow-js-testing";

async function deployContract(param) {
    const [result, error] = await deployContractByName(param);
    if (error != null) {
        console.log(`Error in deployment - ${error}`);
        emulator.stop();
        process.exit(1);
    }
}

describe("LinkedList", () => {
    let serviceAccount;

    beforeEach(async () => {

        const basePath = path.resolve(__dirname, "./../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });

        serviceAccount = await getAccountAddress("ServiceAccount");
    });

    test("Should deploy contract", async () => {

        await deployContract({ to: serviceAccount, name: "SimpleMarket" })
        const SimpleMarket = await getContractAddress("SimpleMarket")
        const addressMap = { SimpleMarket }


        const contractTemplate = await getContractCode({
            name: "SimpleMarket",
            addressMap,
        })
        console.log({ contractTemplate })
    });

    afterEach(async () => {
        await emulator.stop()
    })
})