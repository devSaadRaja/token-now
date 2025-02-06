const formatEth = (wei) => Number(ethers.utils.formatEther(String(wei)));

const parseEth = (eth) => ethers.utils.parseEther(String(eth));
const parseUnits = (eth, units) => ethers.utils.parseUnits(String(eth), units);

const delay = (ms) => new Promise((res) => setTimeout(res, ms));

const contractDeploy = async (name, args, libraries) => {
  const contractFactory = await ethers.getContractFactory(name, libraries);
  const contract = await contractFactory.deploy(...args);
  await contract.deployTransaction.wait();

  console.info(`Deploying ${name} : ${contract.address}`);

  return contract;
};

const verify = async (address, constructorArguments, libraries) => {
  console.log("Verifying contract...");
  try {
    await run("verify:verify", { address, constructorArguments, libraries });
  } catch (e) {
    if (e.message.toLowerCase().includes("already verified")) {
      console.log("Already verified!");
    } else console.log(e);
  }
};

const verifyTenderly = async (name, address, libraries) => {
  console.log("Verifying contract...");
  try {
    await tenderly.verify({ name, address, libraries });
  } catch (e) {
    if (e.message.toLowerCase().includes("already verified")) {
      console.log("Already verified!");
    } else {
      console.log(e);
    }
  }
};

// "contracts/Greeter.sol"
const verifyMultiCompilerAPI = async (
  name,
  contractPath,
  address,
  libraries
) => {
  await tenderly.verifyMultiCompilerAPI({
    contracts: [
      {
        contractToVerify: name,
        sources: {
          contractPath: {
            name: name,
            code: readFileSync(contractPath, "utf-8").toString(),
          },
        },
        compiler: {
          version: "0.8.17",
          settings: {
            optimizer: {
              enabled: true,
              runs: 200,
            },
          },
          libraries,
        },
        networks: {
          [8453]: {
            address,
          },
        },
      },
    ],
  });
};

module.exports = {
  formatEth,
  parseEth,
  parseUnits,
  delay,
  contractDeploy,
  verify,
  verifyTenderly,
  verifyMultiCompilerAPI,
};
