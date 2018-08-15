require('dotenv').config();
require('babel-register')({
  ignore: /node_modules\/(?!zeppelin-solidity\/test\/helpers)/
});
require('babel-polyfill');

var HDWalletProvider = require("truffle-hdwallet-provider");

var mnemonic = process.env.MNEMONIC;
//or privateKey = "*";

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id 
    },
    kovan: {
      provider: new HDWalletProvider(mnemonic, `https://kovan.infura.io/${process.env.INFURA_API_KEY}`),
      network_id: 42,
      gas: 4000000,
      gasPrice: 21000000000
    },
    mainnet: {
      provider: new HDWalletProvider(mnemonic, `https://mainnet.infura.io/${process.env.INFURA_API_KEY}`),
      network_id: 1,
      gas: 4000000,
      gasPrice: 21000000000
    }
  },
  solc: {
    optimizer: {
      enabled: false,
      runs: 200
    }
  },
};