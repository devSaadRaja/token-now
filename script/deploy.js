const { tenderly } = require("hardhat");
const { resolve } = require("path");
const { config } = require("dotenv");
const { readFileSync, writeFileSync } = require("fs");
const {
  contractDeploy,
  verify,
  verifyTenderly,
  parseEth,
} = require("../utils/helper_functions");

config({ path: resolve(__dirname, "./.env") });

var contractsPath = {
  RealEstateToken: "src/RealEstateToken.sol:RealEstateToken",
};

var outputFilePaths = {
  mainnet: "./tenderly_deployments.json",
};

var chainData = {
  mainnet: { rpcUrl: process.env.TENDERLY_MAINNET_URL, chainId: 1 },
};

let outputFilePath = outputFilePaths.mainnet;
let deployments = JSON.parse(readFileSync(outputFilePath, "utf-8"));
let provider = new ethers.providers.JsonRpcProvider(
  chainData.mainnet.rpcUrl,
  chainData.mainnet.chainId
);

var signers = [new ethers.Wallet(process.env.PRIVATE_KEY, provider)];

async function deploy() {
  // const params = [signers[0].address, ""];
  // const RealEstateToken = await contractDeploy("RealEstateToken", params);
  // deployments["RealEstateToken"] = RealEstateToken.address;
  // await verifyTenderly("RealEstateToken", deployments["RealEstateToken"]);
  // // await RealEstateToken.deployTransaction.wait(5);
  // // await verify(deployments["RealEstateToken"], params);
  // writeFileSync(outputFilePath, JSON.stringify(deployments, null, 2));

  // ==============================================================

  let realEstateToken = await ethers.getContractAt(
    contractsPath.RealEstateToken,
    deployments["RealEstateToken"],
    signers[0]
  );
  // await realEstateToken.addMinter(signers[0].address);
  // await realEstateToken.mint(
  //   signers[0].address,
  //   111,
  //   1,
  //   "https://stickerbook.nyc3.digitaloceanspaces.com/1736767552388-stkr-book.png",
  //   ethers.utils.formatBytes32String("")
  // );
}

async function main() {
  await deploy();
}

function addressToBytes32(_addr) {
  return "0x".concat(_addr.slice(2).padStart(64, "0"));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
