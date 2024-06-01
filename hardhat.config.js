require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.4",
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
    imports: ["./lib/v4-core", "./lib/v4-periphery"]
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
    sepolia: {
      url: "https://sepolia.infura.io/v3/a36d0802465e413ab9464be0ac68bc80",
      accounts: [process.env.ACCOUNT1_SECRET_KEY]
    }
  }
};
