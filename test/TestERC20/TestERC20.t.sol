// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../../lib/forge-std/src/Test.sol";
import "../../src/TestERC20/TestERC20.sol";

contract ContractTest is Test {
    TestERC20 token;

    address alice = vm.addr(0x1);
    address bob = vm.addr(0x2);

    error ERC20InvalidReceiver(address receiver);
    error ERC20InvalidSender(address sender);

    function setUp() public {
        token = new TestERC20("Test ERC20 Token", "TERC20", address(this));
    }

    function testName() external view {
        assertEq("Test ERC20 Token", token.name());
    }

    function testSymbol() external view {
        assertEq("TERC20", token.symbol());
    }

    function testMint() public {
        token.mint(alice, 2e18);
        assertEq(token.totalSupply(), token.balanceOf(alice));
    }

    function testBurn() public {
        token.mint(alice, 10e18);
        assertEq(token.balanceOf(alice), 10e18);
        token.burn(alice, 8e18);
        assertEq(token.totalSupply(), 2e18);
        assertEq(token.balanceOf(alice), 2e18);
    }

    function testApprove() public {
        assertTrue(token.approve(alice, 1e18));
        assertEq(token.allowance(address(this), alice), 1e18);
    }

    function testTransfer() external {
        testMint();
        vm.startPrank(alice);
        token.transfer(bob, 0.5e18);
        assertEq(token.balanceOf(bob), 0.5e18);
        assertEq(token.balanceOf(alice), 1.5e18);
        vm.stopPrank();
    }

    function testTransferFrom() external {
        testMint();
        vm.prank(alice);
        token.approve(address(this), 1e18);
        assertTrue(token.transferFrom(alice, bob, 0.7e18));
        assertEq(token.allowance(alice, address(this)), 1e18 - 0.7e18);
        assertEq(token.balanceOf(alice), 2e18 - 0.7e18);
        assertEq(token.balanceOf(bob), 0.7e18);
    }

    /*****************************/
    /*      Fuzz Testing         */
    /*****************************/

    function testFuzzMint(address to, uint256 amount) external {
        vm.assume(to != address(0));
        token.mint(to, amount);
        assertEq(token.totalSupply(), token.balanceOf(to));
    }

    function testFuzzBurn(address from, uint256 mintAmount, uint256 burnAmount) external {
        vm.assume(from != address(0));
        burnAmount = bound(burnAmount, 0, mintAmount);
        token.mint(from, mintAmount);
        token.burn(from, burnAmount);
        assertEq(token.totalSupply(), mintAmount - burnAmount);
        assertEq(token.balanceOf(from), mintAmount - burnAmount);
    }

    function testFuzzApprove(address to, uint256 amount) external {
        vm.assume(to != address(0));
        assertTrue(token.approve(to, amount));
        assertEq(token.allowance(address(this), to), amount);
    }

    function testFuzzTransfer(address to, uint256 amount) external {
        vm.assume(to != address(0));
        vm.assume(to != address(this));
        token.mint(address(this), amount);

        assertTrue(token.transfer(to, amount));
        assertEq(token.balanceOf(address(this)), 0);
        assertEq(token.balanceOf(to), amount);
    }

    function testFuzzTransferFrom(address from, address to, uint256 approval, uint256 amount) external {
        vm.assume(from != address(0));
        vm.assume(to != address(0));

        amount = bound(amount, 0, approval);
        token.mint(from, amount);

        vm.prank(from);
        assertTrue(token.approve(address(this), approval));

        assertTrue(token.transferFrom(from, to, amount));
        assertEq(token.totalSupply(), amount);

        if (approval == type(uint256).max){
            assertEq(token.allowance(from, address(this)), approval);
        } else {
            assertEq(token.allowance(from, address(this)), approval - amount);
        }

        if (from == to) {
            assertEq(token.balanceOf(from), amount);
        } else {
            assertEq(token.balanceOf(from), 0);
            assertEq(token.balanceOf(to), amount);
        }
    }

}