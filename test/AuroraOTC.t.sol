// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/AuroraOTC.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

import "forge-std/Test.sol";

contract ContractTest is Test {
    AuroraOTC otc;
    address user1 = address(10);
    address user2 = address(11);
    address user3 = address(12);
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
        emit log_named_uint("User balance", token1.balanceOf(user1));
        emit log_named_uint("Contract balance", token1.balanceOf(address(otc)));
        otc.createDeal(address(token1), address(token2), amount1, amount2);
        emit log_named_uint("User balance", token1.balanceOf(user1));
        emit log_named_uint("Contract balance", token1.balanceOf(address(otc)));
    }

    function testCreateAndRemoveDeal() public {
        vm.startPrank(user1);
        token1.approve(address(otc), 2**256 - 1);
        otc.createDeal(address(token1), address(token2), amount1, amount2);
        otc.removeDeal(0);
        outputBalances();
    }

    function testCreateAndAcceptDeal() public {
        vm.startPrank(user1);
        token1.approve(address(otc), 2**256 - 1);
        emit log("before");
        outputBalances();
        otc.createDeal(address(token1), address(token2), amount1, amount2);
        vm.stopPrank();
        vm.startPrank(user2);
        token2.approve(address(otc), 2**256 - 1);
        otc.acceptDeal(0);
        emit log("after");
        outputBalances();
    }

    function outputBalances() public {
        emit log("TOKEN 1 BALANCES : ");
        emit log_named_uint("User1", token1.balanceOf(user1));
        emit log_named_uint("User2", token1.balanceOf(user2));
        emit log_named_uint("Contract", token1.balanceOf(address(otc)));
        emit log("TOKEN 2 BALANCES : ");
        emit log_named_uint("User1", token2.balanceOf(user1));
        emit log_named_uint("User2", token2.balanceOf(user2));
        emit log_named_uint("Contract", token2.balanceOf(address(otc)));
    }

     function testCannotCreateDealWithoutTokens() public {
        vm.startPrank(user3);
        token1.approve(address(otc), 2**256 - 1);
        emit log("before");
        outputBalances();
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        otc.createDeal(address(token1), address(token2), amount1, amount2);
    }

    function testCannotAcceptDealWithoutTokens() public {
        vm.startPrank(user1);
        token1.approve(address(otc), 2**256 - 1);
        emit log("before");
        outputBalances();
        otc.createDeal(address(token1), address(token2), amount1, amount2);
        vm.stopPrank();
        vm.startPrank(user3);
        token2.approve(address(otc), 2**256 - 1);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        otc.acceptDeal(0);
    }
}
