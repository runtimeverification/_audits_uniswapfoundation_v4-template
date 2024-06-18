// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Test} from "forge-std/Test.sol";
// TODO(palina): unused import
// import {Currency} from "v4-core/src/types/Currency.sol";
import {MockERC6909Claims} from "v4-core/src/test/MockERC6909Claims.sol";
import {KontrolCheats} from "kontrol-cheatcodes/KontrolCheats.sol";


contract ERC6909ClaimsTest is Test, KontrolCheats {
    MockERC6909Claims token;

    function setUp() public {
        token = new MockERC6909Claims();
    }

    function test_burnFrom_revertsWithNoApproval() public {
        token.mint(address(this), 1337, 100);

        vm.prank(address(0xBEEF));
        vm.expectRevert();
        token.burnFrom(address(this), 1337, 100);
    }

    function prove_burnFrom_revertsWithNoApproval(address caller, uint256 id, uint256 amount) public {
        kevm.symbolicStorage(address(token));
        // `caller` is a fresh symbolic address
        vm.assume(caller != address(token));
        vm.assume(caller != address(this));
        vm.assume(caller != address(vm));
        // `caller` is not an operator of `address(this)`
        vm.assume(!(token.isOperator(address(this), caller)));
        // `allowance` is insufficient
        vm.assume(token.allowance(address(this), caller, id) < amount);

        vm.prank(address(caller));

        vm.expectRevert();
        token.burnFrom(address(this), id, amount);
    }

    /// ---- Tests copied from solmate ---- ///

    function testMint() public {
        token.mint(address(0xBEEF), 1337, 100);

        assertEq(token.balanceOf(address(0xBEEF), 1337), 100);
    }

    function testMint(address receiver, uint256 id, uint256 amount) public {
        token.mint(receiver, id, amount);

        assertEq(token.balanceOf(receiver, id), amount);
    }

    function proveMint(address receiver, uint256 id, uint256 amount) public {
        address sender = kevm.freshAddress();
        vm.assume(sender != address(token));

        vm.prank(sender);
        token.mint(receiver, id, amount);

        assertEq(token.balanceOf(receiver, id), amount);
    }
}
