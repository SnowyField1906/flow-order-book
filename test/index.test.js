import path from "path"
import { init, emulator, getAccountAddress, deployContractByName, getContractAddress, getTransactionCode, getScriptCode, executeScript, sendTransaction } from "flow-js-testing";

jest.setTimeout(100000);

beforeAll(async () => {
    const basePath = path.resolve(__dirname, "../");
    const port = 8080;

    await init(basePath, { port });
    await emulator.start(port);
});

afterAll(async () => {
    const port = 8080;
    await emulator.stop(port);
});

describe("Replicate Playground Accounts", () => {
    test("Create Accounts", async () => {
        // Playground project support 4 accounts, but nothing stops you from creating more by following the example laid out below
        const Alice = await getAccountAddress("Alice");
        const Bob = await getAccountAddress("Bob");
        const Charlie = await getAccountAddress("Charlie");
        const Dave = await getAccountAddress("Dave");

        console.log(
            "Four Playground accounts were created with following addresses"
        );
        console.log("Alice:", Alice);
        console.log("Bob:", Bob);
        console.log("Charlie:", Charlie);
        console.log("Dave:", Dave);
    });
});

describe("Deployment", () => {

    test("Deploy ExampleNFT contract", async () => {
        const name = "ExampleNFT";
        const to = await getAccountAddress("Bob");

        let result;
        try {
            result = await deployContractByName({
                name,
                to,
            });
        } catch (e) {
            console.log(e);
        }
        console.log(result);

        expect(name).toBe("ExampleNFT");
    });

});

describe("Transactions", () => {
    test("test transaction template Mint NFT", async () => {
        const name = "Mint NFT";

        // Import participating accounts
        const Bob = await getAccountAddress("Bob");
        const Alice = await getAccountAddress("Alice")

        // Set transaction signers
        const signers = [Bob];

        // Generate addressMap from import statements
        const ExampleNFT = await getContractAddress("ExampleNFT");

        const addressMap = {
            ExampleNFT,
        };

        let code = await getTransactionCode({
            name,
            addressMap,
        });
        code = code.replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
            const accounts = {
                "0x01": Alice,
                "0x02": Bob,
            };
            const name = accounts[match];
            return `getAccount(${name})`;
        });

        let txResult;
        try {
            txResult = await sendTransaction({
                code,
                signers,
            });
        } catch (e) {
            console.log(e);
        }
        console.log(txResult);

        // expect(txResult.errorMessage).toBe("");
    });
    test("test transaction Setup Account for user", async () => {
        const name = "Setup Account";

        // Import participating accounts
        const Alice = await getAccountAddress("Alice");

        // Set transaction signers
        const signers = [Alice];

        // Generate addressMap from import statements
        const ExampleNFT = await getContractAddress("ExampleNFT");
        const addressMap = {
            ExampleNFT,
        };

        let code = await getTransactionCode({
            name,
            addressMap,
        });


        let txResult;
        try {
            txResult = await sendTransaction({
                code,
                signers,
                // args,
            });
        } catch (e) {
            console.log(e);
        }
        console.log("tx Result", txResult);

        // expect(txResult[0].errorMessage).toBe("");
    });

    test("test transaction template Transfer", async () => {
        const name = "Transfer";

        // Import participating accounts
        const Bob = await getAccountAddress("Bob");
        const Alice = await getAccountAddress("Alice")

        // Set transaction signers
        const signers = [Bob];

        // Generate addressMap from import statements
        const ExampleNFT = await getContractAddress("ExampleNFT");

        const addressMap = {
            ExampleNFT,
        };

        let code = await getTransactionCode({
            name,
            addressMap,
        });

        // pass corrected addressed to getAccount calls
        code = code.replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
            const accounts = {
                "0x01": Alice,
                "0x02": Bob,
            };
            const name = accounts[match];
            return `getAccount(${name})`;
        });

        let txResult;
        try {
            txResult = await sendTransaction({
                code,
                signers,
            });
        } catch (e) {
            console.log(e);
        }

        console.log(txResult);

        // expect(txResult.errorMessage).toBe("");
    });
});

describe("Scripts", () => {
    test("test script template Print 0x02 NFTs", async () => {
        const name = "Print 0x02 NFTs";

        // Import participating accounts
        const Bob = await getAccountAddress("Bob");
        const Alice = await getAccountAddress("Alice")

        // Generate addressMap from import statements
        const ExampleNFT = await getContractAddress("ExampleNFT");

        const addressMap = {
            ExampleNFT,
        };

        let code = await getScriptCode({
            name,
            addressMap,
        });

        // pass corrected addressed to getAccount calls
        code = code.replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
            const accounts = {
                "0x01": Alice,
                "0x02": Bob,
            };
            const name = accounts[match];
            return `getAccount(${name})`;
        });

        const result = await executeScript({
            code,
        });

        console.log(result);
        // Add your expectations here
        expect().toBe();
    });

    test("test script template Print All NFTs", async () => {
        const name = "Print All NFTs";

        // Import participating accounts
        const Bob = await getAccountAddress("Bob");
        const Alice = await getAccountAddress("Alice")
        // Generate addressMap from import statements
        const ExampleNFT = await getContractAddress("ExampleNFT");

        const addressMap = {
            ExampleNFT,
        };

        let code = await getScriptCode({
            name,
            addressMap,
        });

        // pass corrected addressed to getAccount calls
        code = code.replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
            const accounts = {
                "0x01": Alice,
                "0x02": Bob,
            };
            const name = accounts[match];
            return `getAccount(${name})`;
        });

        const result = await executeScript({
            code,
        });
        console.log(result);

        // Add your expectations here
        expect().toBe();
    });
});