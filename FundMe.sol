// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {PriceConverter} from "./PriceConverter.sol";


error notOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant minimumUsd = 5e18;

    address public immutable i_owner;

    address[] public funders;
    mapping(address funder => uint256 AmountFunded) public addressToAmountFunded;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
       require(msg.value.getConversionRate() >= minimumUsd, "didn't send enough ETH");
       funders.push(msg.sender);
       addressToAmountFunded[msg.sender] += msg.value;
    }

    modifier onlyOwner() {
    //    require(msg.sender == i_owner, "sender must be owner");
       if(msg.sender != i_owner) {revert notOwner();}
       _;
    }

    function withdraw() public onlyOwner {
        
        for (uint256 fundersIndex = 0;fundersIndex >= funders.length; fundersIndex++) {
           address funder = funders[fundersIndex];
           addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);

        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Call failed");
    }

    receive() external payable { 
        fund();
    }

    fallback() external payable { 
        fund();
    }



}
