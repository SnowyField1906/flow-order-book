import path from "path"
import { init, emulator, getContractAddress, getContractCode, getTransactionCode, getScriptCode } from "@onflow/flow-js-testing";

import { contractNames, scriptNames, transactionNames } from "../file-names.js"

describe("Template contracts", () => {
    beforeEach(async () => {
        const basePath = path.resolve(__dirname, "./../../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });
    });

    test("Should get contract code", async () => {
        const contract = await getContractAddress(contractNames[0])
        const addressMap = { contract }

        const contractTemplate = await getContractCode({
            name: contractNames[0],
            addressMap,
        })
        expect(contractTemplate).toBeDefined()
    });

    afterEach(async () => {
        await emulator.stop()
    })
})

describe("Template scripts", () => {
    beforeEach(async () => {
        const basePath = path.resolve(__dirname, "./../../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });
    });

    scriptNames.forEach((name, i) => {
        test(`Should get script code ${i}`, async () => {
            const contract = await getContractAddress(contractNames[0])
            const addressMap = { contract }

            const scriptTemplate = await getScriptCode({
                "name": name,
                addressMap
            })
            expect(scriptTemplate).toBeDefined()
        });
    })


    afterEach(async () => {
        await emulator.stop()
    })
});

describe("Template transactions", () => {
    let names = [
        "0. Setup account",
        "1. Make offer",
        "2. Take offer",
    ]

    beforeEach(async () => {
        const basePath = path.resolve(__dirname, "./../../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });
    });

    transactionNames.forEach((name, i) => {
        test(`Should get transaction code ${i}`, async () => {
            const contract = await getContractAddress(contractNames[0])
            const addressMap = { contract }

            const transactionTemplate = await getTransactionCode({
                "name": name,
                addressMap
            })
            expect(transactionTemplate).toBeDefined()
        });
    })


    afterEach(async () => {
        await emulator.stop()
    })
});