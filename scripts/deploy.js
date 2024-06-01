const { ethers } = require("hardhat");

async function main() {
  // Deploy CustomGloveCurve
  const CustomGloveCurve = await ethers.getContractFactory("CustomGloveCurve");
  const customGloveCurve = await CustomGloveCurve.deploy(/* constructor arguments */);
  await customGloveCurve.deployed();
  console.log("CustomGloveCurve deployed to:", customGloveCurve.address);

  // Deploy DynamicGloveFee
  const DynamicGloveFee = await ethers.getContractFactory("DynamicGloveFee");
  const dynamicGloveFee = await DynamicGloveFee.deploy(/* constructor arguments */);
  await dynamicGloveFee.deployed();
  console.log("DynamicGloveFee deployed to:", dynamicGloveFee.address);

  // Deploy GLOVE
  const initialSupply = ethers.utils.parseEther("1000"); // 1000 GLOVE
  const GLOVE = await ethers.getContractFactory("GLOVE");
  const glove = await GLOVE.deploy(initialSupply, customGloveCurve.address, dynamicGloveFee.address);
  await glove.deployed();
  console.log("GLOVE deployed to:", glove.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });