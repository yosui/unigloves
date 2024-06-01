// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./CustomGloveCurve.sol";
import "./DynamicGloveFee.sol";

contract GLOVE is ERC20 {
    CustomGloveCurve public immutable customCurve;
    DynamicGloveFee public immutable dynamicFee;
    uint256 public constant MAX_SUPPLY = 1000e18;

    constructor(uint256 initialSupply, CustomGloveCurve _customCurve, DynamicGloveFee _dynamicFee)
        ERC20("Unigloves", "GLOVE")
    {
        require(initialSupply <= MAX_SUPPLY, "Initial supply exceeds max supply");
        customCurve = _customCurve;
        dynamicFee = _dynamicFee;
        _mint(msg.sender, initialSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function buy(uint256 amount) public payable {
        require(amount > 0, "Amount must be greater than zero");
        require(totalSupply() + amount <= MAX_SUPPLY, "Purchase exceeds max supply");

        uint256 price = customCurve.getAmountInForExactOutput(amount, address(0), address(this), true);
        uint256 fee = dynamicFee.getFee();
        uint256 totalCost = price + (price * fee) / 10000;

        require(msg.value >= totalCost, "Insufficient payment");

        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }

        _mint(msg.sender, amount);
    }

    function sell(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        uint256 proceeds = customCurve.getAmountOutFromExactInput(amount, address(this), address(0), true);
        uint256 fee = dynamicFee.getFee();
        uint256 netProceeds = proceeds - (proceeds * fee) / 10000;

        _burn(msg.sender, amount);
        payable(msg.sender).transfer(netProceeds);
    }

    receive() external payable {
        uint256 amount = msg.value;
        buy(amount);
    }
}
