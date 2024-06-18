// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {Vm} from "forge-std/Vm.sol";

import {Constants} from "v4-core/src/../test/utils/Constants.sol";
import {CurrencyLibrary, Currency} from "v4-core/src/types/Currency.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {Pool} from "v4-core/src/libraries/Pool.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolManager} from "v4-core/src/PoolManager.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {KontrolUtils} from "./utils/KontrolUtils.sol";


contract KontrolProof is KontrolUtils {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;

    PoolManager manager;
    Currency currency0;
    Currency currency1;

    PoolKey uninitializedKey;

    function setUpInlined() public {
        manager = PoolManager(poolManagerAddress);
        currency0 = Currency.wrap(currency0Address);
        currency1 = Currency.wrap(currency1Address);

        uninitializedKey = PoolKey({
            currency0: currency0,
            currency1: currency1,
            fee: 3000,
            hooks: IHooks(Constants.ADDRESS_ZERO),
            tickSpacing: 60
        });
    }

    function prove_initialize_revertsWithIdenticalTokens(uint160 sqrtPriceX96) public {
        setUpInlined();

        vm.assume(sqrtPriceX96 >= TickMath.MIN_SQRT_PRICE);
        vm.assume(sqrtPriceX96 <= TickMath.MAX_SQRT_PRICE - 1);

        // Both currencies are currency0
        uninitializedKey.currency1 = currency0;

        vm.expectRevert(IPoolManager.CurrenciesOutOfOrderOrEqual.selector);
        manager.initialize(uninitializedKey, sqrtPriceX96, Constants.ZERO_BYTES);
    }

    function prove_initialize_failsIfTickSpaceZero(uint160 sqrtPriceX96) public {
        setUpInlined();

        vm.assume(sqrtPriceX96 >= TickMath.MIN_SQRT_PRICE);
        vm.assume(sqrtPriceX96 <= TickMath.MAX_SQRT_PRICE - 1);

        // Tick spacing is 0
        uninitializedKey.tickSpacing = 0;

        vm.expectRevert(abi.encodeWithSelector(IPoolManager.TickSpacingTooSmall.selector));
        manager.initialize(uninitializedKey, sqrtPriceX96, Constants.ZERO_BYTES);
    }
}