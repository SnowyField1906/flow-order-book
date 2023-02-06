import path from "path"
import { init, emulator, deployContractByName, getContractAddress, getContractCode, getTransactionCode, getScriptCode } from "@onflow/flow-js-testing";

import { addressMap, contractNames, scriptNames, transactionNames } from "../helpers.js"


describe("Template contracts", () => {
    beforeAll(async () => {
        const basePath = path.resolve(__dirname, "./../../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });
    });

    test("Should get contract code", async () => {
        const contractTemplate = await getContractCode({
            name: contractNames[0],
            addressMap,
        })
        expect(contractTemplate).toBeDefined()
    });

    afterAll(async () => {
        await emulator.stop()
    })
})

describe("Template scripts", () => {
    beforeAll(async () => {
        const basePath = path.resolve(__dirname, "./../../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });
    });

    scriptNames.forEach((name, i) => {
        test(`Should get script code ${i}`, async () => {
            const scriptTemplate = await getScriptCode({
                "name": name,
                addressMap
            })
            expect(scriptTemplate).toBeDefined()
        });
    })


    afterAll(async () => {
        await emulator.stop()
    })
});

describe("Template transactions", () => {
    beforeAll(async () => {
        const basePath = path.resolve(__dirname, "./../../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });
    });

    transactionNames.forEach((name, i) => {
        test(`Should get transaction code ${i}`, async () => {
            const transactionTemplate = await getTransactionCode({
                "name": name,
                addressMap
            })
            // console.log(transactionTemplate)
            expect(transactionTemplate).toBeDefined()
        });
    })


    afterAll(async () => {
        await emulator.stop()
    })
});