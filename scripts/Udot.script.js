const {ethers} = require("hardhat");

async function main() {

  const UDOT = await ethers.getContractFactory("UDOT");
  const udot = await UDOT.deploy();

  console.log("Contract deployed to:", udot.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
