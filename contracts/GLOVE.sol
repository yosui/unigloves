// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./CustomGloveCurve.sol";
import "./DynamicGloveFee.sol";

contract GLOVE is ERC20 {
    CustomGloveCurve public immutable customCurve;
    DynamicGloveFee public immutable dynamicFee;

    constructor(uint256 initialSupply, CustomGloveCurve _customCurve, DynamicGloveFee _dynamicFee)
        ERC20("Unigloves", "GLOVE")
    {
        customCurve = _customCurve;
        dynamicFee = _dynamicFee;
        _mint(msg.sender, initialSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function buy(uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than zero");

        // Get the current price from the custom curve
        uint256 price = customCurve.getAmountInForExactOutput(amount, Currency.wrap(address(0)), Currency.wrap(address(this)), true);

        // Get the current fee from the dynamic fee contract
        uint256 fee = dynamicFee.getFee();

        // Calculate the total cost including the fee
        uint256 totalCost = price + (price * fee) / 10000; // Assuming fee is in basis points (1/10000)

        require(msg.value >= totalCost, "Insufficient payment");

        // Transfer excess payment back to the buyer
        if (msg.value > totalCost) {
            payable(msg.sender).send(msg.value - totalCost);
        }

        // Mint GLOVE tokens to the buyer
        _mint(msg.sender, amount);
    }

    function sell(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        // Get the current price from the custom curve
        uint256 proceeds = customCurve.getAmountOutFromExactInput(amount, Currency.wrap(address(this)), Currency.wrap(address(0)), true);

        // Get the current fee from the dynamic fee contract
        uint256 fee = dynamicFee.getFee();

        // Calculate the proceeds after deducting the fee
        uint256 netProceeds = proceeds - (proceeds * fee) / 10000; // Assuming fee is in basis points (1/10000)

        // Burn GLOVE tokens from the seller
        _burn(msg.sender, amount);

        // Transfer proceeds to the seller
        payable(msg.sender).send(netProceeds);
    }

    // Optional: Add a receive function to allow the contract to receive ETH directly
    receive() external payable {
        buy(msg.value);
    }
}