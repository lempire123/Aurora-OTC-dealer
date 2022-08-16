// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/AuroraOTC.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

import "forge-std/Test.sol";

contract ContractTest is Test {
    AuroraOTC otc;
    address user1 = address(1);
    address user2 = address(2);
    address user3 = address(3);
    ERC20 token1 = new ERC20("1", "1");
    ERC20 token2 = new ERC20("2", "2");
    uint256 amount1 = 10;
    uint256 amount2 = 50;
    
    function setUp() public {
        otc = new AuroraOTC();
        deal(address(token1), user1, 100);
        deal(address(token2), user2, 100);
    }

    function testCreateDeal() public {
        vm.startPrank(user1);
        token1.approve(address(otc), 2**256 - 1);
        otc.createDeal(address(token1), address(token2), amount1, amount2);
        assert(token1.balanceOf(user1) == 90);
        assert(token1.balanceOf(address(otc)) == 10);
    }

    function testCreateAndRemoveDeal() public {
        vm.startPrank(user1);
        token1.approve(address(otc), 2**256 - 1);
        otc.createDeal(address(token1), address(token2), amount1, amount2);
        otc.removeDeal(0);
        assert(token1.balanceOf(user1) == 100);
        assert(token1.balanceOf(address(otc)) == 0);
    }

    function testCreateAndAcceptDeal() public {
        vm.startPrank(user1);
        token1.approve(address(otc), 2**256 - 1);
        otc.createDeal(address(token1), address(token2), amount1, amount2);
        vm.stopPrank();
        vm.startPrank(user2);
        token2.approve(address(otc), 2**256 - 1);
        otc.acceptFullDeal(0);
        assert(token1.balanceOf(user1) == 90);
        assert(token1.balanceOf(user2) == 10);
        assert(token2.balanceOf(user1) == 50);
        assert(token2.balanceOf(user2) == 50);
    }

    function testPartialDeal() public {
        vm.startPrank(user1);
        token1.approve(address(otc), 2**256 - 1);
        otc.createDeal(address(token1), address(token2), amount1, amount2);
        vm.stopPrank();
        vm.startPrank(user2);
        token2.approve(address(otc), 2**256 - 1);
        otc.acceptDeal(0, 1);
        assert(token1.balanceOf(user2) == 1);
        assert(token2.balanceOf(user1) == 5);
        assert(token2.balanceOf(user2) == 95);
        otc.acceptDeal(0, 1);
        assert(token1.balanceOf(user2) == 2);
        assert(token2.balanceOf(user1) == 10);
        assert(token2.balanceOf(user2) == 90);
        otc.acceptDeal(0, 1);
        assert(token1.balanceOf(user2) == 3);
        assert(token2.balanceOf(user1) == 15);
        assert(token2.balanceOf(user2) == 85);
    }

    function testPartialDealAndRemove() public {
        vm.startPrank(user1);
        token1.approve(address(otc), 2**256 - 1);
        otc.createDeal(address(token1), address(token2), amount1, amount2);
        vm.stopPrank();
        vm.startPrank(user2);
        token2.approve(address(otc), 2**256 - 1);
        otc.acceptDeal(0, 1);
        assert(token1.balanceOf(user2) == 1);
        assert(token2.balanceOf(user1) == 5);
        assert(token2.balanceOf(user2) == 95);
        vm.stopPrank();
        vm.startPrank(user1);
        otc.removeDeal(0);
        assert(token1.balanceOf(user1) == 99);
        assert(token1.balanceOf(user2) == 1);
        assert(token2.balanceOf(user1) == 5);
        assert(token2.balanceOf(user2) == 95);
    }

     function testCannotCreateDealWithoutTokens() public {
        vm.startPrank(user3);
        token1.approve(address(otc), 2**256 - 1);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        otc.createDeal(address(token1), address(token2), amount1, amount2);
    }

    function testCannotAcceptDealWithoutTokens() public {
        vm.startPrank(user1);
        token1.approve(address(otc), 2**256 - 1);
        otc.createDeal(address(token1), address(token2), amount1, amount2);
        vm.stopPrank();
        vm.startPrank(user3);
        token2.approve(address(otc), 2**256 - 1);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        otc.acceptFullDeal(0);
    }
}
