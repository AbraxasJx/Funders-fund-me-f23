//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentlyDepolyed) public {
        FundMe(payable(mostRecentlyDepolyed)).fund{value: SEND_VALUE}();
        console.log ("Funded FundMe with %s", SEND_VALUE);      
    }

    function run() external  {
    address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe",
    block.chainid
    );
    vm.startBroadcast();
    fundFundMe(mostRecentlyDeployed);
    vm.stopBroadcast();
    }
}

contract WithDrawFundMe is Script{
    function withDrawFundMe(address mostRecentlyDepolyed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDepolyed)).withDraw();
         vm.stopBroadcast();
       
      
    }

    function run() external view {
    address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe",
    block.chainid
    );
    WithDrawFundMe(mostRecentlyDeployed);
     }
    }

    
