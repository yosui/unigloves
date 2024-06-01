// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CustomCurveBase} from "./CustomCurveBase.sol";
import {Currency} from "@uniswap/v4-core/contracts/types/Currency.sol";

contract CustomGloveCurve is CustomCurveBase {
    uint256 private constant A = 0.001e18;
    uint256 private constant B = 1.00461e18;
    uint256 private constant P_MAX = 3e18;
    uint256 private constant GLOVE_TOTAL_SUPPLY = 1000e18;

    constructor(IPoolManager _manager) CustomCurveBase(_manager) {}

    function getAmountOutFromExactInput(uint256 amountIn, Currency input, Currency output, bool zeroForOne)
        internal
        view
        override
        returns (uint256 amountOut)
    {
        require(input == Currency.wrap(address(0)) && output == Currency.wrap(address(this)), "Invalid currencies");
        require(zeroForOne, "Only supports ETH to GLOVE");
        uint256 stock = GLOVE_TOTAL_SUPPLY - totalSupply();
        uint256 price = A * B ** stock / 1e18;
        price = price > P_MAX ? P_MAX : price;
        amountOut = (amountIn * 1e18) / price;
    }

    function getAmountInForExactOutput(uint256 amountOut, Currency input, Currency output, bool zeroForOne)
        internal
        view
        override
        returns (uint256 amountIn)
    {
        require(input == Currency.wrap(address(0)) && output == Currency.wrap(address(this)), "Invalid currencies");
        require(zeroForOne, "Only supports ETH to GLOVE");
        uint256 stock = GLOVE_TOTAL_SUPPLY - totalSupply() - amountOut;
        uint256 price = A * B ** stock / 1e18;
        price = price > P_MAX ? P_MAX : price;
        amountIn = (amountOut * price) / 1e18;
    }

    function getCurrentPrice() external view returns (uint256) {
        uint256 stock = GLOVE_TOTAL_SUPPLY - totalSupply();
        uint256 price = A * B ** stock / 1e18;
        return price > P_MAX ? P_MAX : price;
    }
}