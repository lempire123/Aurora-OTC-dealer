// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/**
    @title Aurora OTC desk
    @author Lance Henderson

    @notice Aurora OTC desk is a contract that allows anyone to set up an OTC deal 
            that they would like to execute with any counterparty. 
            The easiest way to undersand the use case is through an example :
            Bob has 10 BTC he would like to exchange for USDC tokens, at the current 
            market price of 20k USDC / BTC. He could do so by swapping them on a DEX 
            such as Trisolaris, but would have to incur a significant slippage fee. 
            Instead he can use Aurora OTC desk to create an "offer" of 10 btc for 
            200k USDC (20k x 10), which anyone looking to buy btc can accept
 */

contract AuroraOTC {

    // Array of available deals
    Deal[] public deals;

    /*////////////////////////////////////
                   EVENTS
    ////////////////////////////////////*/

    // @notice Emitted when a deal is created
    // @param token0 Token provided by the owner of the deal
    // @param token1 Token the owner wishes to receive
    // @param owner Address of the creator of the deal
    event dealCreation(
        address indexed token0, 
        address indexed token1, 
        address indexed owner
        );

    // @notice Emitted when a deal is created
    // @param index Index of the deal deleted
    event dealDeletion(
        uint256 index
        );
    
    // @notice Emitted when a deal is created
    // @param maker Address of the owner of the deal
    // @param taker Address of the acceptor of the deal
    // @param time Time at which deal was accepted
    event dealCompletion(
        address indexed maker, 
        address indexed taker, 
        uint256 indexed time
        );

    // @notice Deal represents an OTC offer made by an address
    // @param token0 Token provided by the owner of the deal
    // @param token1 Token the owner wishes to receive
    // @param amount0 Amount of token0
    // @param amount1 Amount of token1
    // @param time Time at which deal was created
    // @param owner Address of the creator of the deal
    struct Deal {
        IERC20 token0;
        IERC20 token1;
        uint256 amount0;
        uint256 amount1;
        uint256 time;
        address owner;
    }

    /*////////////////////////////////////
             EXTERNAL FUNCTIONS
    ////////////////////////////////////*/

    // @notice Allows anyone to setup an OTC offer
    // @param _token0 Token provided by the creator of the deal
    // @param _token1 Token provided by the person accepting the deal
    // @param _amount0 Amount of token0
    // @param _amount1 Amount of token1
    function createDeal(
        address _token0,
        address _token1,
        uint256 _amount0,
        uint256 _amount1
    ) external {
        Deal newDeal = Deal(
            IERC20(_token0),
            IERC20(_token1),
            _amount0,
            _amount1,
            block.timestamp,
            msg.sender
        );
        deals.push(newDeal);
        IERC20(_token0).transferFrom(msg.sender, address(this), _amount0);

        emit dealCreation(_token0, _token1, msg.sender);

    }

    // @notice Allows anyone to remove a deal from the marketplace
    // The sender must obviously be the owner of said deal
    // @param _index Index of the deal to remove
    function removeDeal(uint256 _index) public {
        require(deals[_index].owner == msg.sender, "ONLY OWNER CAN REMOVE DEAL");
        deals[_index] = deals[deals.length - 1];
        deals.pop();
        deals[_index].token0.transfer(msg.sender, deals[_index].amount0);

        emit dealDeletion(_index);
    }

    // @notice Helper function to remove all deals in which sender is the owner
    function removeAllDeals() external {
        uint256 length = deals.length;
        for(uint256 i; i < length; i++) {
            if(deals[i].owner == msg.sender) {
                removeDeal(i);
            }
        }
    }

    // @notice Allows anyone to accept an offer from the deals array
    // @param _index Index of the deal they would like to accept
    function acceptDeal(uint256 _index) external {
        Deal currentDeal = deals[_index];
        currentDeal.token1.transferFrom(msg.sender, currentDeal.owner, currentDeal.amount1);
        currentDeal.token0.transfer(msg.sender, currentDeal.amount0);

        emit dealCompletion(currentDeal.owner, msg.sender, block.timestamp);
    }

    
}
