require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-foundry");
// require("@nomiclabs/hardhat-etherscan");

const { resolve } = require("path");
const { config } = require("dotenv");
config({ path: resolve(__dirname, "./.env") });

const tenderly = require("@tenderly/hardhat-tenderly");
tenderly.setup({ automaticVerirication: false });

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.22",
        settings: {
          metadata: { bytecodeHash: "none" },
          optimizer: { enabled: true, runs: 10 },
        },
      },
    ],
  },
  mocha: {
    timeout: 200000,
  },
  networks: {
    localhost: {
      timeout: 120000,
    },
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    tenderly: {
      url: process.env.TENDERLY_MAINNET_URL,
      chainId: 1,
      accounts: [process.env.PRIVATE_KEY],
    },
    baseSepolia: {
      url: process.env.BASE_SEPOLIA_RPC,
      chainId: 84532,
      accounts: [process.env.PRIVATE_KEY],
    },
    // mainnet: {
    //   url: `https://eth-mainnet.g.alchemy.com/v2/${process.env.MAINNET_ALCHEMY_API_KEY}`,
    //   chainId: 1,
    //   accounts: [process.env.MAINNET_PRIVATE_KEY],
    // },
  },
  tenderly: {
    username: "saadraja",
    project: "project",

    // Contract visible only in Tenderly.
    // Omitting or setting to `false` makes it visible to the whole world.
    // Alternatively, control verification visibility using
    // an environment variable `TENDERLY_PRIVATE_VERIFICATION`.
    privateVerification: true,
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY,
      tenderly: process.env.ETHERSCAN_API_KEY,
      baseSepolia: process.env.BASESCAN_API_KEY,
      // mainnet: process.env.ETHERSCAN_API_KEY,
      // mainnet: process.env.MAINNET_ETHERSCAN_API_KEY,
    },
  },
};
