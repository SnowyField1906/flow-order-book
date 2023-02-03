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

describe("2. Make offer", () => {
    let serviceAccount;
    let txTemplate;
    let contractName = "SimpleMarket"
    let txName = "2. Make offer"

    beforeEach(async () => {

        const basePath = path.resolve(__dirname, "./../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });

        serviceAccount = await getAccountAddress("ServiceAccount");
        await deployContract({ to: serviceAccount, name: contractName })
    });

    test("Should get template code", async () => {
        const SimpleMarket = await getContractAddress(contractName)
        const addressMap = { SimpleMarket }

        txTemplate = await getTransactionCode({
            name: txName,
            addressMap,
        })
        expect(txTemplate).not.toBeNull()
    });

    test("Should send transaction", async () => {
        const Alice = await getAccountAddress("Alice")
        const Bob = await getAccountAddress("Bob")

        const signers = [Alice, Bob]
        const args = [serviceAccount, 0x02, 1, 0x03, 2]

        const [txInlineResult] = await shallPass(
            sendTransaction({ "code": txTemplate, signers, args })
        )
        const [txFileResult, , fileLogs] = await shallPass(
            sendTransaction({ "name": txName, signers, args })
        )
        const [txShortResult, , inlineLogs] = await shallPass(
            sendTransaction(txName, signers, args)
        )

        expect(fileLogs).toEqual(expectedLogs)
        expect(inlineLogs).toEqual(expectedLogs)

        expect(txFileResult).toEqual(txInlineResult)
        expect(txShortResult).toEqual(txInlineResult)

        console.log({ txShortResult, inlineLogs })
    });

    afterEach(async () => {
        await emulator.stop()
    })
})