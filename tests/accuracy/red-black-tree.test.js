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

describe("Red Black Tree", () => {
    const traversal = `
    import RedBlackTree from ./../contracts/SimpleMarket.cdc

    access(all) var keys: [UInt32] = []

    pub fun inorder(key: UInt32?) {
        if (RedBlackTree.nodes[key!] == nil) {
            return;
        }
        inorder(key: RedBlackTree.nodes[key!]?.left);
        keys.append(key!)
        inorder(key: RedBlackTree.nodes[key!]?.right);
    }

    pub fun main(): [UInt32] {
        inorder(key: RedBlackTree.root)
        return keys
    }
 
    `
    const insert = `
    import RedBlackTree from ./../contracts/SimpleMarket.cdc

    transaction(key: UInt32) {
        prepare(acct: AuthAccount) {}

        execute {
            RedBlackTree.insert(key: key)
        }
    }
    `

    const args = Array(100)
        .fill()
        .map((_, i) => i + 1)
        .sort(() => 0.5 - Math.random())


    beforeAll(async () => {
        const basePath = path.resolve(__dirname, "./../../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });

        await deployContract({ name: "RedBlackTree" })
    });

    args.forEach(arg => {
        test(`Should insert ${arg}`, async () => {
            const Alice = await getAccountAddress("Alice")
            let signers = [Alice]
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
        console.log(keys);
    });



    afterAll(async () => {
        await emulator.stop()
    })
})
