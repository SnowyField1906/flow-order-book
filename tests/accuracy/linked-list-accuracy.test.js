import path from "path"
import { init, emulator, getAccountAddress, getContractAddress, getTransactionCode, sendTransaction, shallPass } from "@onflow/flow-js-testing";

describe("1. Make offer", () => {
    let serviceAccount;
    let txTemplate;
    let contractName = "SimpleMarket"
    let txName = "1. Make offer"

    beforeEach(async () => {
        const basePath = path.resolve(__dirname, "./../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });
    });

    test("Should get template code", async () => {
        const SimpleMarket = await getContractAddress(contractName)
        const addressMap = { SimpleMarket }

        txTemplate = await getTransactionCode({
            name: txName,
            addressMap,
        })
        expect(txTemplate).toBeDefined()
    });

    test("Should send transaction", async () => {
        const Alice = await getAccountAddress("Alice")
        const Bob = await getAccountAddress("Bob")

        const signers = [Alice, Bob]
        const args = [serviceAccount, "0x02", "1", "0x03", "2"]

        const [txInlineResult] = await shallPass(
            sendTransaction(
                {
                    "code": txTemplate,
                    "signers": signers,
                    "args": args
                })
        )
        const [txFileResult, , fileLogs] = await shallPass(
            sendTransaction({
                "name": txName,
                "signers": signers,
                "args": args
            })
        )
        const [txShortResult, , inlineLogs] = await shallPass(
            sendTransaction(txName, signers, args)
        )

        expect(fileLogs).toEqual(expectedLogs)
        expect(inlineLogs).toEqual(expectedLogs)

        expect(txFileResult).toEqual(txInlineResult)
        expect(txShortResult).toEqual(txInlineResult)
    });

    afterEach(async () => {
        await emulator.stop()
    })
})