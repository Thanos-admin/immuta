const hre = require("hardhat");

async function main() {
  // Mainnet addresses
  const OWNER         = "0x34CbC11b975303396a77b4758F01E19cdAb31426";
  const FEE_RECIPIENT = "0x4e81cc07E09dfA86A3a224ff41b541551E9b3929";
  const USDC          = "0x15D38573d2feeb82e7ad5187aB8c1D52810B1f07";
  const USDT          = "0x0Cb6F5a34ad42ec934882A05265A7d5F59b51A2f";
  const DAI           = "0xefD766cCb38EaF1dfd701853BFCe31359239F305";

  console.log("Deploying Immuta to PulseChain mainnet...");
  console.log("Owner:         ", OWNER);
  console.log("Fee recipient: ", FEE_RECIPIENT);
  console.log("USDC:          ", USDC);
  console.log("USDT:          ", USDT);
  console.log("DAI:           ", DAI);

  const Immuta = await hre.ethers.getContractFactory("Immuta");
  const immuta = await Immuta.deploy(OWNER, FEE_RECIPIENT, USDC, USDT, DAI);
  await immuta.waitForDeployment();

  const address = await immuta.getAddress();
  console.log("------------------------------------------");
  console.log("Immuta deployed to:", address);
  console.log("------------------------------------------");
  console.log("Save this address. You will need it for the frontend.");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
