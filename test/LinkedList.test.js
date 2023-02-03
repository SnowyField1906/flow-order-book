import path from "path"
import { init, emulator, getAccountAddress, sendTransaction, shallPass } from "@onflow/flow-js-testing";

async function deployContract(param) {
    const [result, error] = await deployContractByName(param);
    if (error != null) {
        console.log(`Error in deployment - ${error}`);
        emulator.stop();
        process.exit(1);
    }
}

describe("LinkedList", () => {
    let serviceAccount;

    beforeEach(async () => {

        const basePath = path.resolve(__dirname, "./../");
        const logging = false;

        await init(basePath);
        await emulator.start({ logging });

        serviceAccount = await getAccountAddress("ServiceAccount");

        await deployContract({ to: serviceAccount, name: "FungibleToken" });
        await deployContract({ to: serviceAccount, name: "utility/NonFungibleToken" });
        await deployContract({ to: serviceAccount, name: "utility/MetadataViews" });
        await deployContract({ to: serviceAccount, name: "FungibleTokenMetadataViews" });
        await deployContract({ to: serviceAccount, name: "ExampleToken" });

        // ...and finally we get the address for a couple of regular accounts
        exampleTokenUserA = await getAccountAddress("exampleTokenUserA");
        exampleTokenUserB = await getAccountAddress("exampleTokenUserB");

    });


    test("get account address", async () => {


        const Alice = await getAccountAddress("Alice")

        // Expect Alice to be address of Alice's account
        expect(isAddress(Alice)).toBe(true)
    })

    afterEach(async () => {
        await emulator.stop()
    })
})