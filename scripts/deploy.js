const hre = require("hardhat");
const { ethers } = hre;

async function main() {
  const decimals = 18;
  const initialSupply = ethers.utils.parseUnits("1000", decimals);

  // Deploy GLOVE token
  const GLOVEToken = await ethers.getContractFactory("GLOVE");
  const gloveToken = await GLOVEToken.deploy(initialSupply);
  await gloveToken.deployed();
  console.log("GLOVE token deployed to:", gloveToken.address);

  const poolManagerAddress = "0xd2b7230A770EA70A19369Ad6806Ba708e47DE08b";

  // Deploy CustomGloveCurve
  const CustomGloveCurve = await ethers.getContractFactory("CustomGloveCurve");
  const customGloveCurve = await CustomGloveCurve.deploy(poolManagerAddress);
  await customGloveCurve.deployed();
  console.log("CustomGloveCurve deployed to:", customGloveCurve.address);

  // Deploy DynamicGloveFee
  try {
    const DynamicGloveFee = await ethers.getContractFactory("DynamicGloveFee");
    const dynamicGloveFee = await DynamicGloveFee.deploy(poolManagerAddress);
    await dynamicGloveFee.deployed();
    console.log("DynamicGloveFee deployed to:", dynamicGloveFee.address);
  } catch (err) {
    console.log("DynamicGloveFee contract not found or failed to deploy:", err.message);
  }

  console.log("Deployment completed successfully!");
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
