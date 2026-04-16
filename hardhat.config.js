require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");

module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      evmVersion: "shanghai",
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    pulsechainTestnet: {
      url: "https://pulsechain-testnet-rpc.publicnode.com",
      chainId: 943,
      accounts: [process.env.PRIVATE_KEY],
    },
    pulsechain: {
      url: "https://rpc.pulsechainstats.com",
      chainId: 369,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      pulsechain: "abc"
    },
    customChains: [
      {
        network: "pulsechain",
        chainId: 369,
        urls: {
          apiURL: "https://scan.pulsechain.com/api?module=contract&action=verify",
          browserURL: "https://scan.pulsechain.com"
        }
      }
    ]
  },
  sourcify: {
    enabled: true
  }
};
