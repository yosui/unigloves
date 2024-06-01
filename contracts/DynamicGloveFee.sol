// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BaseHook} from "@uniswap/v4-periphery/contracts/BaseHook.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";
import {CustomGloveCurve} from "./CustomGloveCurve.sol";


contract DynamicGloveFee is BaseHook {
    CustomGloveCurve public immutable customCurve;

    uint256 public constant a = 0.4999e18; // 0.4999 in 18 decimal places
    int256 public constant b = -0.0069e18; // -0.0069 in 18 decimal places
    uint256 public constant c = 0.001e18; // 0.001 in 18 decimal places

    constructor(IPoolManager _poolManager, CustomGloveCurve _customCurve) BaseHook(_poolManager) {
        customCurve = _customCurve;
    }

    function beforeSwap(address, PoolKey calldata, IPoolManager.SwapParams calldata, bytes calldata)
        external
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        uint256 stock = customCurve.getStock();
        uint256 fee = a * exp(b * int256(stock)) / 1e18 + c;

        // Override the fee
        uint256 overrideFee = fee | uint256(LPFeeLibrary.OVERRIDE_FEE_FLAG);
        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, uint24(overrideFee));
    }

    function afterInitialize(address, PoolKey calldata key, uint160, int24, bytes calldata)
        external
        override
        returns (bytes4)
    {
        poolManager.updateDynamicLPFee(key, uint24(a * exp(b * 1000) / 1e18 + c));
        return BaseHook.afterInitialize.selector;
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: true,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function exp(int256 x) internal pure returns (uint256) {
        int256 sum = 1e18; // 1 * 10^18
        int256 term = 1e18; // x^0 / 0!
        for (uint256 i = 1; i < 20; i++) {
            term = (term * x) / int256(i * 1e18);
            sum += term;
        }
        return uint256(sum);
    }

    function getFee() public view returns (uint256) {
        uint256 stock = customCurve.getStock();
        return a * exp(b * int256(stock)) / 1e18 + c;
    }

}