require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("solidity-docgen");
require("dotenv").config();

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
	solidity: {
		version: "0.8.8",
		settings: {
			optimizer: {
			enabled: true,
			runs: 200,
			},
		},
	},
  networks: {
    hardhat: {
      forking: {
        url: process.env.POLYGON_MAINNET_URL,
        blockNumber: 35609317,
      }
    },
    polygon: {
        url: process.env.POLYGON_MAINNET_URL,
        accounts:{
          mnemonic: process.env.MNEMONIC
        },
    },
    mumbai: {
      url: process.env.MUMBAI_URL,
      accounts:{
        mnemonic: process.env.MNEMONIC
      },
    },
  },
  etherscan: {
    apiKey: {
      polygon: process.env.POLYGONSCAN_API_KEY,
      polygonMumbai: process.env.POLYGONSCAN_API_KEY
    }
  },
  gasReporter: {
    enabled: true,
    currency: 'USD',
    token: "MATIC",
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
  },
};
