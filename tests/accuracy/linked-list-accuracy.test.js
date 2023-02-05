import path from "path"
import { init, emulator, deployContractByName, getAccountAddress, getContractAddress, getTransactionCode, sendTransaction, shallPass, executeScript, shallResolve } from "@onflow/flow-js-testing";

import { addressMap, contractNames, transactionNames, scriptTemplates, transactionTemplates } from "../helpers.js"

async function deployContract(param) {
    const [, error] = await deployContractByName(param);
    if (error != null) {
        console.log(`Error in deployment - ${error}`);
        emulator.stop();
        process.exit(1);
    }
}

describe("Output", () => {
    let txName = transactionNames[1]

    beforeEach(async () => {
        const basePath = path.resolve(__dirname, "./../../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });

        await deployContract({ name: contractNames[0] })
    });

    test("Should store and query exactly offers and ids", async () => {
        const Alice = await getAccountAddress("Alice")

        const signers = [Alice]

        const expectedOffers = [
            {
                uuid: '26',
                maker: signers[0],
                payToken: '0x0000000000000002',
                payAmount: '2.00000000',
                buyToken: '0x0000000000000003',
                buyAmount: '5.00000000'
            },
            {
                uuid: '27',
                maker: signers[0],
                payToken: '0x0000000000000002',
                payAmount: '1.00000000',
                buyToken: '0x0000000000000003',
                buyAmount: '3.00000000'
            }
        ]


        await shallPass(
            sendTransaction({
                "code": transactionTemplates[1],
                "signers": signers,
                "args": [
                    expectedOffers[0].payToken,
                    expectedOffers[0].payAmount,
                    expectedOffers[0].buyToken,
                    expectedOffers[0].buyAmount
                ]
            }))
        await shallPass(
            sendTransaction({
                "code": transactionTemplates[1],
                "signers": signers,
                "args": [
                    expectedOffers[1].payToken,
                    expectedOffers[1].payAmount,
                    expectedOffers[1].buyToken,
                    expectedOffers[1].buyAmount
                ]
            }))

        const [offers,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[0],
                "args": []
            }))
        const [ids,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[1],
                "args": []
            }))
        const [prices,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[2],
                "args": []
            }))

        const expectedIDs = Object.keys(offers)
        const expectedPrices = Object.values(expectedOffers).map(offer =>
            +offer.buyAmount / +offer.payAmount
        )
        const expectedAdjacencies0 = ["0", expectedIDs[1]]
        const expectedAdjacencies1 = [expectedIDs[0], "0"]

        console.log(expectedAdjacencies0, expectedAdjacencies1)
        const [adjacencies0,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[6],
                "args": [+expectedIDs[0]]
            }))
        const [adjacencies1,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[6],
                "args": [+expectedIDs[1]]
            }))

        console.log("Offers =", offers)
        console.log("IDs =", ids)
        console.log("Prices =", prices)
        console.log(`Adjacencies' ${expectedIDs[0]}:`, adjacencies0)
        console.log(`Adjacencies' ${expectedIDs[1]}:`, adjacencies1)

        expect(Object.values(offers)).toEqual(expectedOffers)
        expect(Object.values(ids)).toEqual(expectedIDs)
        expect(Object.values(prices).map(price =>
            parseFloat(price))
        ).toEqual(expectedPrices)
        expect(Object.values(adjacencies0)).toEqual(expectedAdjacencies0)
        expect(Object.values(adjacencies1)).toEqual(expectedAdjacencies1)
    });

    afterEach(async () => {
        await emulator.stop()
    })
})