const { expect } = require("chai");
const { ethers } = require("@nomicfoundation/hardhat-ethers");

describe("GLOVE", function () {
  let GLOVE;
  let glove;
  let CustomGloveCurve;
  let customGloveCurve;
  let DynamicGloveFee;
  let dynamicGloveFee;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy CustomGloveCurve
    CustomGloveCurve = await ethers.getContractFactory("CustomGloveCurve");
    customGloveCurve = await CustomGloveCurve.deploy(owner.address); // Use owner's address as the pool manager
    await customGloveCurve.deployed();

    // Deploy DynamicGloveFee
    DynamicGloveFee = await ethers.getContractFactory("DynamicGloveFee");
    dynamicGloveFee = await DynamicGloveFee.deploy(owner.address); // Use owner's address as the pool manager
    await dynamicGloveFee.deployed();

    // Deploy GLOVE
    GLOVE = await ethers.getContractFactory("GLOVE");
    glove = await GLOVE.deploy(ethers.utils.parseEther("1000"), customGloveCurve.address, dynamicGloveFee.address);
    await glove.deployed();
  });

  it("Should have correct name, symbol, and decimals", async function () {
    expect(await glove.name()).to.equal("Unigloves");
    expect(await glove.symbol()).to.equal("GLOVE");
    expect(await glove.decimals()).to.equal(18);
  });

  it("Should mint initial supply to owner", async function () {
    expect(await glove.totalSupply()).to.equal(ethers.utils.parseEther("1000"));
    expect(await glove.balanceOf(owner.address)).to.equal(ethers.utils.parseEther("1000"));
  });

  it("Should allow users to buy GLOVE tokens with ETH", async function () {
    const initialBalance = await glove.balanceOf(addr1.address);
    const ethAmount = ethers.utils.parseEther("1");

    await glove.connect(addr1).buy(ethAmount, { value: ethAmount });

    const finalBalance = await glove.balanceOf(addr1.address);
    expect(finalBalance).to.be.gt(initialBalance);
  });

  it("Should allow users to sell GLOVE tokens for ETH", async function () {
    const initialEthBalance = await ethers.provider.getBalance(addr2.address);
    const gloveAmount = ethers.utils.parseEther("100");

    await glove.transfer(addr2.address, gloveAmount);
    await glove.connect(addr2).sell(gloveAmount);

    const finalEthBalance = await ethers.provider.getBalance(addr2.address);
    expect(finalEthBalance).to.be.gt(initialEthBalance);
  });
});