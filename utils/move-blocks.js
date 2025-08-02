const { network } = require("hardhat");

async function moveBlocks(amount) {
  console.log("----------------");
  console.log("Moving blocks...");
  for (let index = 0; index < amount; index++) {
    await network.provider.request({ method: "evm_mine", params: [] });
  }
  console.log(`Moved ${amount} block(s)`);
  console.log("----------------");
}

module.exports = { moveBlocks };
