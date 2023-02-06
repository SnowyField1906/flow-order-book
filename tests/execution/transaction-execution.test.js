import path from "path"
import { init, emulator, deployContractByName, getAccountAddress, getContractAddress, getTransactionCode, sendTransaction, shallPass } from "@onflow/flow-js-testing";

import { addressMap, contractNames, transactionNames } from "../helpers.js"

async function deployContract(param) {
    const [, error] = await deployContractByName(param);
    if (error != null) {
        console.log(`Error in deployment - ${error}`);
        emulator.stop();
        process.exit(1);
    }
}

describe("1. Make offer", () => {
    let txTemplate = `
    import SimpleMarket from 0xf8d6e0586b0a20c7

    transaction(payToken: Address, payAmount: UFix64, buyToken: Address, buyAmount: UFix64) {
    
        let maker: Address
    
        prepare(acct: AuthAccount) {
            self.maker = acct.address
        }
    
        execute {
            let offer = SimpleMarket.makeOffer(self.maker, payToken, payAmount, buyToken, buyAmount)    
        }
    }
     `
    // let txTemplate = getTransactionCode({
    //     name: transactionNames[1],
    //     addressMap
    // })
    let txName = transactionNames[1]

    beforeAll(async () => {
        const basePath = path.resolve(__dirname, "./../../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });

        await deployContract({ name: contractNames[0] })
    });

    test("Should send transaction", async () => {
        const Alice = await getAccountAddress("Alice")

        const signers = [Alice]
        const args = ["0x02", "1", "0x03", "3"]

        const [txInlineResult] = await shallPass(
            sendTransaction({
                "code": txTemplate,
                "signers": signers,
                "args": args
            }))

        // const [txFileResult, , fileLogs] = await shallPass(
        //     sendTransaction({
        //         "name": txName,
        //         "signers": signers,
        //         "args": args
        //     }))

        // const [txShortResult, , inlineLogs] = await shallPass(
        //     sendTransaction(txName, signers, args)
        // )


        // expect(fileLogs).toEqual(expectedLogs)
        // expect(inlineLogs).toEqual(expectedLogs)

        // console.log(fileLogs, inlineLogs)
        // console.log(txFileResult, txInlineResult, txShortResult)

        // expect(fileLogs).toEqual(inlineLogs)
        // expect(txFileResult).toEqual(txInlineResult)
        // expect(txShortResult).toEqual(txInlineResult)


        let expectedResult = {
            blockId: '',
            status: 4,
            statusString: 'SEALED',
            statusCode: 0,
            errorMessage: '',
            events: []
        }

        expect(txInlineResult).toEqual(expectedResult)
    });

    afterAll(async () => {
        await emulator.stop()
    })
})