// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {console2 as console} from "forge-std/console2.sol";

import {CounterTest} from "../Counter.t.sol";
import {RecordStateDiff} from "./recordStateDiff/RecordStateDiff.sol";
import {CurrencyLibrary, Currency} from "v4-core/src/types/Currency.sol";

/* This contract is to be run with the kdeploy profile prior to running the proofs */
/* It is used to create the appropriate JSON files to load the initial configuration to Kontrol */
contract SetupStateDiff is CounterTest, RecordStateDiff {
    using CurrencyLibrary for Currency;

    // Runs _setUp producing a json with all state updates
    function setUpStateDiff() public recordStateDiff {
        setUp();
    }

    // Records _setUp state updates and the name of the relevant addresses
    function test_setup_and_save_addresses() public {
        setUpStateDiff();
        save_address("poolManager", address(manager));
        save_address("feeController", address(feeController));
        save_address("currency0", Currency.unwrap(currency0));
        save_address("currency1", Currency.unwrap(currency1));
        save_address("modifyLiquidityRouter", address(modifyLiquidityRouter));
    }
}