//SPDX-License-Identifier: MIT

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithDrawFundMe} from "../../script/Interaction.s.sol";

pragma solidity ^0.8.18;

contract FundMeTest is Test {
FundMe fundMe;
address USER = makeAddr("user");
uint256 constant SEND_VALUE = 0.1 ether;
uint256 constant STARTING_BALANCE = 100 ether;

    function setUp() external {
      DeployFundMe deployFundMe = new DeployFundMe();
      fundMe = deployFundMe.run();
      vm.deal(USER, STARTING_BALANCE);
    }


    function testMinimumDollarsIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        
    }

    function testOwnerIsSender() public view {
       assertEq(fundMe.getOwner(), msg.sender);

    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth () public{
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);

    }

    function testAddFundersToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);

    }

    modifier funded {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withDraw();
    }

    
    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFundersIndex = 1;
        for(uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            hoax (address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

         uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withDraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);

    }

function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFundersIndex = 1;
        for(uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            hoax (address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

         uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
       assert(fundMe.getOwner().balance == startingOwnerBalance + startingFundMeBalance);

    }
 
}



