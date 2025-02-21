
// require("solidity-coverage");
// require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-truffle5");
require("@nomiclabs/hardhat-waffle");
require("@nomicfoundation/hardhat-verify");

//https://hardhat.org/plugins/hardhat-gas-reporter.html
// require("hardhat-contract-sizer");
// require("hardhat-gas-reporter");

const env = require('./.env.json');
// const accounts = require('./accounts.json');

module.exports = {
  etherscan: {
    apiKey: {
      mainnet: env.ETHERSCAN_API_KEY,
      base: env.BASESCAN_API_KEY,
      sepolia: env.SEPOLIA_API_KEY
    },
    // for hardhat verify
    customChains: [
      {
        network: "base-sepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://sepolia.base.org",
          browserURL: "https://sepolia.basescan.org"
        }
      }
    ],
  },
  sourcify: {
    enabled: true
  },
  mocha: {
    timeout: 20000
  },
  paths: {
    artifacts: "./artifacts",
    cache:     "./cache",
    sources:   "./contracts",
    tests:     "./test",
  },
  solidity: {
    settings: env.COMPILER_SETTINGS,
    version: env.COMPILER_VERSION,
  },
  // ref: https://hardhat.org/hardhat-network/docs/reference
  networks: {
    hardhat: {
      // accounts: accounts,
      forking: {
        enabled: true,
        // url: `https://mainnet.infura.io/v3/${env.INFURA.PROJECT_ID}`
        url: 'https://mainnet.base.org'
      },
    },

    "base-sepolia": {
      url: 'https://sepolia.base.org',
      accounts: [ env.ACCOUNTS.WALLET.PK ],
      // gasPrice: 100_000_000,
    },
    "base-mainnet": {
      url: 'https://mainnet.base.org',
      accounts: [ env.ACCOUNTS.WALLET.PK ],
      // gasPrice: 100_000_000,
    },

    "blast-mainnet": {
      // Block Explorer: https://blastscan.io
      chainId:  81457,
      url: `https://rpc.blast.io`,
      accounts: [
        env.ACCOUNTS.WALLET.PK,
      ]
    },
    "blast-sepolia": {
      // Block Explorer: https://testnet.blastscan.io
      chainId: 168587773,
      url: `https://sepolia.blast.io`,
      accounts: [
        env.ACCOUNTS.WALLET.PK,
      ]
    },

    goerli: {
      url: `https://goerli.infura.io/v3/${env.INFURA.PROJECT_ID}`,
      accounts: []
    },

    sepolia: {
      url: `https://sepolia.infura.io/v3/${env.INFURA.PROJECT_ID}`,
      accounts: [
        env.ACCOUNTS.WALLET.PK,
        // ...accounts.slice(2).map(acct => acct.privateKey)
      ],
      // gasPrice: 65_000_000_000,
    },

    mainnet: {
      url: `https://mainnet.infura.io/v3/${env.INFURA.PROJECT_ID}`,
      accounts: [],
      gasPrice: 27_000_000_000,
      gas: 4_000_000,
      // nonce: 49
    }
  },
  contractSizer: {
    runOnCompile: false
  },
};
