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

describe("Linked list", () => {
    // let txName = transactionNames[1]

    let signers, currentID

    beforeAll(async () => {
        const basePath = path.resolve(__dirname, "./../../archive");
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
                payAmount: '2.00000000',
                buyAmount: '5.00000000'
            },
            {
                uuid: '27',
                maker: signers[0],
                payAmount: '1.00000000',
                buyAmount: '3.00000000'
            }
        ]
        const expectedIDs = ["0", "1"]
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

        await shallPass(
            sendTransaction({
                "code": transactionTemplates[1],
                "signers": signers,
                "args": [
                    expectedOffers[0].payAmount,
                    expectedOffers[0].buyAmount
                ]
            })
        )

        await shallPass(
            sendTransaction({
                "code": transactionTemplates[1],
                "signers": signers,
                "args": [
                    expectedOffers[1].payAmount,
                    expectedOffers[1].buyAmount
                ]
            })
        )

        const [offers,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[0],
                "args": []
            })
        )
        const [ids,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[1],
                "args": []
            })
        )
        const [prices,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[2],
                "args": []
            })
        )

        const [idDetails0,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[5],
                "args": [+expectedIDs[0]]
            })
        )
        const [idDetails1,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[5],
                "args": [+expectedIDs[1]]
            })
        )

        currentID = await shallResolve(
            executeScript({
                "code": scriptTemplates[7],
                "args": []
            })
        ).then((res) => res[0])

        console.log("Offers =", Object.values(offers))
        console.log("IDs =", ids)
        console.log("Prices =", prices)
        console.log(`ID details =`, [idDetails0, idDetails1])
        console.log(`Current ID =`, currentID)

        expect(Object.values(offers)).toEqual(expectedOffers)
        expect(Object.values(ids)).toEqual(expectedIDs)
        expect(Object.values(prices).map(price =>
            parseFloat(price))
        ).toEqual(expectedPrices)
        expect(idDetails0).toEqual(expectedIDDetails[0])
        expect(idDetails1).toEqual(expectedIDDetails[1])
        expect(currentID).toEqual(expectedIDs[0])
    });


    test("Should store & query exactly offers & ids after having been bought", async () => {
        const expectedOffers = [
            {
                uuid: '28',
                maker: '0x01cf0e2f2f715450',
                payAmount: '1.00000000',
                buyAmount: '2.50000000'
            },
            {
                uuid: '27',
                maker: '0x01cf0e2f2f715450',
                payAmount: '1.00000000',
                buyAmount: '3.00000000'
            }
        ]

        const quantity = 1.00000000
        await shallPass(
            sendTransaction({
                "code": transactionTemplates[2],
                "signers": signers,
                "args": [
                    +currentID,
                    quantity
                ]
            })
        )
        const [offers,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[0],
                "args": []
            })
        )
        console.log("Offers =", Object.values(offers))

        expect(Object.values(offers)).toEqual(expectedOffers)
    });


    test("Should store & query exactly offers & ids after having been moved", async () => {
        const expectedOffers = [
            {
                uuid: '27',
                maker: '0x01cf0e2f2f715450',
                payAmount: '1.00000000',
                buyAmount: '3.00000000'
            }
        ]

        const quantity = 1.00000000

        await shallPass(
            sendTransaction({
                "code": transactionTemplates[2],
                "signers": signers,
                "args": [
                    +currentID,
                    quantity
                ]
            })
        )
        const [newCurrentID,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[7],
                "args": []
            })
        )
        const [newOffers,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[0],
                "args": []
            })
        )
        const [newIDs,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[1],
                "args": []
            })
        )
        const [newPrices,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[2],
                "args": []
            })
        )
        const [newIDDetails,] = await shallResolve(
            executeScript({
                "code": scriptTemplates[5],
                "args": [+newIDs[0]]
            })
        )

        const expectedPrices = Object.values(expectedOffers).map(offer =>
            +offer.buyAmount / +offer.payAmount
        )
        const expectedIDs = Object.keys(newOffers)
        const expectedIDDetails = [
            {
                left: '0',
                right: '0',
            }
        ]

        console.log("Offers =", Object.values(newOffers))
        console.log("IDs =", newIDs)
        console.log("Prices =", newPrices)
        console.log("ID details =", [newIDDetails])
        console.log("Current ID =", newCurrentID)

        expect(Object.values(newOffers)).toEqual(expectedOffers)
        expect(Object.values(newIDs)).toEqual(expectedIDs)
        expect([newIDDetails]).toEqual(expectedIDDetails)
        expect(Object.values(newPrices).map(price =>
            parseFloat(price))
        ).toEqual(expectedPrices)
        expect(newCurrentID).toEqual(expectedIDs[0])
    });

    afterAll(async () => {
        await emulator.stop()
    })
})
