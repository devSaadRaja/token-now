const { network } = require("hardhat");

async function moveTime(amount) {
  console.log("----------------");
  console.log("Moving forward in time...");
  await network.provider.send("evm_increaseTime", [amount]);
  console.log(`Moved ${amount} seconds`);
  console.log("----------------");
}

module.exports = { moveTime };
