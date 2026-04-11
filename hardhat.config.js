require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.19",
  networks: {
    pulsechainTestnet: {
      url: "https://pulsechain-testnet-rpc.publicnode.com",
      chainId: 943,
      accounts: [process.env.PRIVATE_KEY],
    },
    pulsechain: {
      url: "http://15.204.109.176:8545",
      chainId: 369,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};
