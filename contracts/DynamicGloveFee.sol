// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BaseHook} from "../lib/v4-periphery/contracts/BaseHook.sol";
import {Hooks} from "../lib/v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "../lib/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "../lib/v4-core/src/types/PoolKey.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "../lib/v4-core/src/types/BeforeSwapDelta.sol";
import {LPFeeLibrary} from "../lib/v4-core/src/libraries/LPFeeLibrary.sol";
import {CustomGloveCurve} from "./CustomGloveCurve.sol";

contract DynamicGloveFee is BaseHook {
    uint256 private constant P_MAX = 3e18;
    uint256 private constant MAX_FEE = 0.5e18; // 50%

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function beforeSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata, bytes calldata)
        external
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        uint256 price = CustomGloveCurve(address(key.hooks)).getCurrentPrice();
        uint256 fee = (price * MAX_FEE) / P_MAX;
        uint256 overrideFee = fee | uint256(LPFeeLibrary.OVERRIDE_FEE_FLAG);
        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, uint24(overrideFee));
    }

    function afterInitialize(address, PoolKey calldata, uint160, int24, bytes calldata)
        external
        override
        returns (bytes4)
    {
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
}