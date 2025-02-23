// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";


contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;
    // uint number = 1;
    function setUp() external{
        // number = 2;
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); 

        DeployFundMe deployFundme = new DeployFundMe();
        fundMe = deployFundme.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public{
        
        // assertEq(number, 2);
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerisMsgSender() public{
        // console.log(fundMe.i_owner());
        // console.log(msg.sender);
        // console.log(address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionisAccurate() public{
        console.log(fundMe.getVersion());
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundEnoughEth() public{
        vm.expectRevert();
        fundMe.fund();
    }

    function testfunUpdatesFundedDatastructure() public{
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunnded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunnded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public{
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
        //Funding USER address with 10ether
            // vm.prank(USER);
            // fundMe.fund{value: SEND_VALUE}();
        //USER attempts to withdraw but we expect a reverts since USER is not owner
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder()  public funded {
        //Arange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
       
       
        // console.log(gasStart);
        // console.log(gasEnd);
        // console.log(gasUsed);

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance , endingOwnerBalance);
        
    }

    function testWithdrawFromMultipleFunders() public funded{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            //hoax => vm.prank and vm.deal
            fundMe.fund{value: SEND_VALUE}();
        }


        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance
        );



    } 
    function testWithdrawFromMultipleFundersCheaper() public funded{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            //hoax => vm.prank and vm.deal
            fundMe.fund{value: SEND_VALUE}();
        }


        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance
        );



    }
}