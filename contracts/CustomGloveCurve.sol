// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Currency} from "../lib/v4-core/src/types/Currency.sol";

contract CustomGloveCurve {
    uint256 private constant A = 0.001e18;
    uint256 private constant B = 1.00461e18;
    uint256 private constant P_MAX = 3e18;
    uint256 private constant GLOVE_TOTAL_SUPPLY = 1000e18;
    address public poolManager;

    constructor(address _poolManager) {
        poolManager = _poolManager;
    }

    function getAmountOutFromExactInput(uint256 amountIn, address input, address output, bool zeroForOne)
        internal
        view
        returns (uint256 amountOut)
    {
        require(input == address(0) && output == address(this), "Invalid currencies");
        require(zeroForOne, "Only supports ETH to GLOVE");
        uint256 stock = GLOVE_TOTAL_SUPPLY - ERC20(output).totalSupply();
        uint256 price = A * B ** stock / 1e18;
        price = price > P_MAX ? P_MAX : price;
        amountOut = (amountIn * 1e18) / price;
    }

    function getAmountInForExactOutput(uint256 amountOut, address input, address output, bool zeroForOne)
        internal
        view
        returns (uint256 amountIn)
    {
        require(input == address(0) && output == address(this), "Invalid currencies");
        require(zeroForOne, "Only supports ETH to GLOVE");
        uint256 stock = GLOVE_TOTAL_SUPPLY - ERC20(output).totalSupply() - amountOut;
        uint256 price = A * B ** stock / 1e18;
        price = price > P_MAX ? P_MAX : price;
        amountIn = (amountOut * price) / 1e18;
    }

    function getCurrentPrice() external view returns (uint256) {
        uint256 stock = GLOVE_TOTAL_SUPPLY - ERC20(address(this)).totalSupply();
        uint256 price = A * B ** stock / 1e18;
        return price > P_MAX ? P_MAX : price;
    }
}
