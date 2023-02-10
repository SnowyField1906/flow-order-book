import path from "path"
import { init, emulator, deployContractByName, getAccountAddress, getContractAddress, getTransactionCode, sendTransaction, shallPass, executeScript, shallResolve, getScriptCode } from "@onflow/flow-js-testing";

import { addressMap, contractNames, transactionNames, scriptNames } from "../helpers.js"

const deployContract = async (param) => {
    const [, error] = await deployContractByName(param);
    if (error != null) {
        console.log(`Error in deployment - ${error}`);
        emulator.stop();
        process.exit(1);
    }
}

const scriptTemplate = async (name) => {
    return await getScriptCode({
        name: name,
        addressMap: addressMap
    })
}
const transactionTemplate = async (name) => {
    return await getTransactionCode({
        name: name,
        addressMap: addressMap
    })
}

describe("Offers & IDs", () => {
    const signers = Object.values(addressMap)

    const expectedOffers = [
        {
            uuid: '23',
            maker: '0xf8d6e0586b0a20c7',
            payAmount: '4.00000000',
            buyAmount: '9.00000000',
            isBid: true
        },
        {
            uuid: '24',
            maker: '0xf8d6e0586b0a20c7',
            payAmount: '2.00000000',
            buyAmount: '3.00000000',
            isBid: true
        },
        {
            uuid: '25',
            maker: '0xf8d6e0586b0a20c7',
            payAmount: '3.00000000',
            buyAmount: '8.00000000',
            isBid: true
        },
        {
            uuid: '26',
            maker: '0xf8d6e0586b0a20c7',
            payAmount: '2.00000000',
            buyAmount: '5.00000000',
            isBid: true
        },
        {
            uuid: '27',
            maker: '0xf8d6e0586b0a20c7',
            payAmount: '2.00000000',
            buyAmount: '7.00000000',
            isBid: true
        }
    ]
    const expectedIDs = {
        '2.25000000': {
            parent: '0.00000000',
            left: '1.50000000',
            right: '2.66666666',
            red: false
        },
        '1.50000000': {
            parent: '2.25000000',
            left: '0.00000000',
            right: '0.00000000',
            red: false
        },
        '3.50000000': {
            parent: '2.66666666',
            left: '0.00000000',
            right: '0.00000000',
            red: true
        },
        '2.50000000': {
            parent: '2.66666666',
            left: '0.00000000',
            right: '0.00000000',
            red: true
        },
        '2.66666666': {
            parent: '2.25000000',
            left: '2.50000000',
            right: '3.50000000',
            red: false
        }
    }

    beforeAll(async () => {
        const basePath = path.resolve(__dirname, "./../../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });

        await deployContract({ name: contractNames[0] })
    });



    Object.values(expectedOffers).forEach(async (offer) => {
        test(`Should make offer ${offer.buyAmount / offer.payAmount}`, async () => {
            await shallPass(
                sendTransaction({
                    "code": await transactionTemplate(transactionNames[1]),
                    "signers": signers,
                    "args": [+offer.payAmount, +offer.buyAmount, offer.isBid]
                })
            )
        })
    })

    test(`Should get offers & ids`, async () => {
        const [offers,] = await shallResolve(
            executeScript({
                "code": await scriptTemplate(scriptNames[0]),
                "args": []
            })
        )
        const [sortedIDs,] = await shallResolve(
            executeScript({
                "code": await scriptTemplate(scriptNames[2]),
                "args": []
            })
        )

        sortedIDs.forEach(async (id) => {
            const [idDetails,] = await shallResolve(
                executeScript({
                    "code": await scriptTemplate(scriptNames[4]),
                    "args": [id]
                })
            )
            console.log(`ID ${id} =`, idDetails)
            expect(idDetails).toEqual(expectedIDs[id])
        })

        const currentID = await shallResolve(
            executeScript({
                "code": await scriptTemplate(scriptNames[6]),
                "args": []
            })
        ).then((res) => res[0])

        console.log("Offers =", Object.values(offers))
        console.log("IDs =", sortedIDs)
        console.log(`Current ID =`, currentID)


        expect(Object.values(offers)).toEqual(expectedOffers)
        expect(sortedIDs).toEqual(Object.keys(expectedIDs).sort((a, b) => (+a) - (+b)))
        expect(currentID).toEqual(Object.keys(expectedIDs)[0])
    });


    // test("Should store & query exactly offers & ids after having been bought", async () => {
    //     const expectedOffers = [
    //         {
    //             uuid: '28',
    //             maker: '0x01cf0e2f2f715450',
    //             payAmount: '1.00000000',
    //             buyAmount: '2.50000000'
    //         },
    //         {
    //             uuid: '27',
    //             maker: '0x01cf0e2f2f715450',
    //             payAmount: '1.00000000',
    //             buyAmount: '3.00000000'
    //         }
    //     ]

    //     const quantity = 1.00000000
    //     await shallPass(
    //         sendTransaction({
    //             "code": transactionTemplates[2],
    //             "signers": signers,
    //             "args": [
    //                 +currentID,
    //                 quantity
    //             ]
    //         })
    //     )
    //     const [offers,] = await shallResolve(
    //         executeScript({
    //             "code": scriptTemplates[0],
    //             "args": []
    //         })
    //     )
    //     console.log("Offers =", Object.values(offers))

    //     expect(Object.values(offers)).toEqual(expectedOffers)
    // });


    // test("Should store & query exactly offers & ids after having been moved", async () => {
    //     const expectedOffers = [
    //         {
    //             uuid: '27',
    //             maker: '0x01cf0e2f2f715450',
    //             payAmount: '1.00000000',
    //             buyAmount: '3.00000000'
    //         }
    //     ]

    //     const quantity = 1.00000000

    //     await shallPass(
    //         sendTransaction({
    //             "code": transactionTemplates[2],
    //             "signers": signers,
    //             "args": [
    //                 +currentID,
    //                 quantity
    //             ]
    //         })
    //     )
    //     const [newCurrentID,] = await shallResolve(
    //         executeScript({
    //             "code": scriptTemplates[7],
    //             "args": []
    //         })
    //     )
    //     const [newOffers,] = await shallResolve(
    //         executeScript({
    //             "code": scriptTemplates[0],
    //             "args": []
    //         })
    //     )
    //     const [newIDs,] = await shallResolve(
    //         executeScript({
    //             "code": scriptTemplates[1],
    //             "args": []
    //         })
    //     )
    //     const [newPrices,] = await shallResolve(
    //         executeScript({
    //             "code": scriptTemplates[2],
    //             "args": []
    //         })
    //     )
    //     const [newIDDetails,] = await shallResolve(
    //         executeScript({
    //             "code": scriptTemplates[5],
    //             "args": [+newIDs[0]]
    //         })
    //     )

    //     const expectedPrices = Object.values(expectedOffers).map(offer =>
    //         +offer.buyAmount / +offer.payAmount
    //     )
    //     const expectedIDs = Object.keys(newOffers)
    //     const expectedIDDetails = [
    //         {
    //             left: '0',
    //             right: '0',
    //         }
    //     ]

    //     console.log("Offers =", Object.values(newOffers))
    //     console.log("IDs =", newIDs)
    //     console.log("Prices =", newPrices)
    //     console.log("ID details =", [newIDDetails])
    //     console.log("Current ID =", newCurrentID)

    //     expect(Object.values(newOffers)).toEqual(expectedOffers)
    //     expect(Object.values(newIDs)).toEqual(expectedIDs)
    //     expect([newIDDetails]).toEqual(expectedIDDetails)
    //     expect(Object.values(newPrices).map(price =>
    //         parseFloat(price))
    //     ).toEqual(expectedPrices)
    //     expect(newCurrentID).toEqual(expectedIDs[0])
    // });

    afterAll(async () => {
        await emulator.stop()
    })
})
