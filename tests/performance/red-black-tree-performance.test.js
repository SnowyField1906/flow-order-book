import path from "path"
import { init, emulator, deployContractByName, getAccountAddress, getContractAddress, getTransactionCode, sendTransaction, shallPass, executeScript, shallResolve, getScriptCode } from "@onflow/flow-js-testing";

import { addressMap, contractNames, transactionNames, scriptTemplates, transactionTemplates } from "../helpers.js"

import { array } from "../array.js"

async function deployContract(param) {
    const [, error] = await deployContractByName(param);
    if (error != null) {
        console.log(`Error in deployment - ${error}`);
        emulator.stop();
        process.exit(1);
    }
}

describe("Red Black Tree", () => {

    // const args = array
    const args = Array(10)
        .fill()
        .map((_, i) => i + 1)
        .sort(() => 0.5 - Math.random())
    const shufferedArgs = args.sort(() => 0.5 - Math.random()).slice(0, 50)
    const signers = Object.values(addressMap)


    let insert;
    let remove;
    let traversal;
    let detail


    beforeAll(async () => {
        const basePath = path.resolve(__dirname, "./../..");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });

        await deployContract({ name: "RedBlackTree" })

        insert = await getTransactionCode({
            name: "red-black-tree/0. Insert",
            addressMap: addressMap
        })
        remove = await getTransactionCode({
            name: "red-black-tree/1. Remove",
            addressMap: addressMap
        })
        traversal = await getScriptCode({
            name: "red-black-tree/0. Traversal",
            addressMap: addressMap
        })
        detail = await getScriptCode({
            name: "red-black-tree/1. Detail",
            addressMap: addressMap
        })
    });

    args.forEach(arg => {
        test(`Should insert ${arg}`, async () => {
            await shallPass(
                sendTransaction({
                    code: insert,
                    signers: signers,
                    args: [arg]
                })
            )
        });
    });

    test("Should traverse the tree in order", async () => {
        const [keys,] = await executeScript({
            code: traversal
        })
        expect(keys).toEqual(args
            .sort((a, b) => a - b)
            .map(arg => arg.toString())
        )
        console.log("Inorder traversal", keys);

        const [details,] = await executeScript({
            code: detail,
        })
        console.log("Detail", details);
    });

    shufferedArgs.forEach(arg => {
        test(`Should remove ${arg}`, async () => {
            await shallPass(
                sendTransaction({
                    code: remove,
                    signers: signers,
                    args: [arg]
                })
            )
        });
    });

    test("Should traverse the tree in order", async () => {
        const [keys,] = await executeScript({
            code: traversal
        })
        console.log("Inorder traversal", keys);
    });

    shufferedArgs.sort(() => 0.5 - Math.random()).forEach(arg => {
        test(`Should insert ${arg}`, async () => {
            await shallPass(
                sendTransaction({
                    code: insert,
                    signers: signers,
                    args: [arg]
                })
            )
        });
    });

    test("Should traverse the tree in order", async () => {
        const [keys,] = await executeScript({
            code: traversal
        })
        console.log("Inorder traversal", keys);
    });

    shufferedArgs.sort(() => 0.5 - Math.random()).forEach(arg => {
        test(`Should remove ${arg}`, async () => {
            await shallPass(
                sendTransaction({
                    code: remove,
                    signers: signers,
                    args: [arg]
                })
            )
        });
    });

    test("Should traverse the tree in order", async () => {
        const [keys,] = await executeScript({
            code: traversal
        })
        console.log("Inorder traversal", keys);
    });

    shufferedArgs.sort(() => 0.5 - Math.random()).forEach(arg => {
        test(`Should insert ${arg}`, async () => {
            await shallPass(
                sendTransaction({
                    code: insert,
                    signers: signers,
                    args: [arg]
                })
            )
        });
    });

    test("Should traverse the tree in order", async () => {
        const [keys,] = await executeScript({
            code: traversal
        })
        console.log("Inorder traversal", keys);
    });

    shufferedArgs.sort(() => 0.5 - Math.random()).forEach(arg => {
        test(`Should remove ${arg}`, async () => {
            await shallPass(
                sendTransaction({
                    code: remove,
                    signers: signers,
                    args: [arg]
                })
            )
        });
    });

    afterAll(async () => {
        await emulator.stop()
    })
})
