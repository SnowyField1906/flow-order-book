import { config } from "@onflow/fcl";

config({
    "accessNode.api": "https://rest-testnet.onflow.org", // Mainnet: "https://rest-mainnet.onflow.org"
    "discovery.wallet": "https://fcl-discovery.onflow.org/testnet/authn", // Mainnet: "https://fcl-discovery.onflow.org/authn"
    "0xOrderBookV2": "0x9d380238fdd484d7", // The account address where the Profile smart contract lives on Testnet

})