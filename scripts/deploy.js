const hre = require("hardhat");

async function main() {
  const TDAI_ADDRESS = "0x826e4e896CC2f5B371Cd7Bb0bd929DB3e3DB67c0";

  const Immuta = await hre.ethers.getContractFactory("Immuta");
  const immuta = await Immuta.deploy(TDAI_ADDRESS);
  await immuta.waitForDeployment();

  const address = await immuta.getAddress();
  console.log("Immuta deployed to:", address);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
