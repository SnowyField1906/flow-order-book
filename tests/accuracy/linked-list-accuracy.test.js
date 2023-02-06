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
    // let txName = transactionNames[1]

    let signers, offers, ids, prices, currentID

    beforeAll(async () => {
        const basePath = path.resolve(__dirname, "./../../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });

        await deployContract({ name: contractNames[0] })
    });

    test("Should store & query exactly offers & ids after having been made", async () => {
        const Alice = await getAccountAddress("Alice")
        signers = [Alice]
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

        offers = await shallResolve(
            executeScript({
                "code": scriptTemplates[0],
                "args": []
            }))
        ids = await shallResolve(
            executeScript({
                "code": scriptTemplates[1],
                "args": []
            }))
        prices = await shallResolve(
            executeScript({
                "code": scriptTemplates[2],
                "args": []
            }))

        const expectedIDs = Object.keys(offers[0])
        const expectedPrices = Object.values(expectedOffers).map(offer =>
            +offer.buyAmount / +offer.payAmount
        )
        const expectedIDDetails = [
            {
                left: '0',
                right: expectedIDs[1],
            },
            {
                left: expectedIDs[0],
                right: '0',
            }
        ]

        const [idDetails0,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[5],
                "args": [+expectedIDs[0]]
            }))
        const [idDetails1,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[5],
                "args": [+expectedIDs[1]]
            }))
        currentID = await shallResolve(
            executeScript({
                "code": scriptTemplates[7],
                "args": []
            }))

        console.log("Offers =", Object.values(offers[0]))
        console.log("IDs =", ids[0])
        console.log("Prices =", prices[0])
        console.log(`ID details =`, [idDetails0, idDetails1])
        console.log(`Current ID =`, currentID[0])

        expect(Object.values(offers[0])).toEqual(expectedOffers)
        expect(Object.values(ids[0])).toEqual(expectedIDs)
        expect(Object.values(prices[0]).map(price =>
            parseFloat(price))
        ).toEqual(expectedPrices)
        expect(idDetails0).toEqual(expectedIDDetails[0])
        expect(idDetails1).toEqual(expectedIDDetails[1])
        expect(currentID[0]).toEqual(expectedIDs[0])
    });


    test("Should store & query exactly offers & ids after having been bought", async () => {
        const quantity = 1.00000000
        await shallPass(
            sendTransaction({
                "code": transactionTemplates[2],
                "signers": signers,
                "args": [
                    +currentID[0],
                    quantity
                ]
            }))
        offers = await shallResolve(
            executeScript({
                "code": scriptTemplates[0],
                "args": []
            }))
        console.log("Offers =", Object.values(offers[0]))
    });

    test("Should store & query exactly offers & ids after having been moved", async () => {
        const quantity = 1.00000000
        await shallPass(
            sendTransaction({
                "code": transactionTemplates[2],
                "signers": signers,
                "args": [
                    +currentID[0],
                    quantity
                ]
            }))
        currentID = await shallResolve(
            executeScript({
                "code": scriptTemplates[7],
                "args": []
            }))

        offers = await shallResolve(
            executeScript({
                "code": scriptTemplates[0],
                "args": []
            }))
        ids = await shallResolve(
            executeScript({
                "code": scriptTemplates[1],
                "args": []
            }))
        prices = await shallResolve(
            executeScript({
                "code": scriptTemplates[2],
                "args": []
            }))
        const [idDetails,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[5],
                "args": [+ids[0]]
            }))

        console.log("Offers =", Object.values(offers[0]))
        console.log("IDs =", ids[0])
        console.log("Prices =", prices[0])
        console.log(`ID details =`, [idDetails])
        console.log(`Current ID =`, currentID[0])

    });

    afterAll(async () => {
        await emulator.stop()
    })
})