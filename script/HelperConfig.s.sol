//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMAL = 8;
    int public constant INITIAL_ANSWER = 2000e8;

    
    struct NetworkConfig{
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
     } else if (block.chainid == 1) {
        activeNetworkConfig = getMainNetConfig();
     } else (activeNetworkConfig = getOrCreateAnvilEthConfig());
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory sepoliaConfig = NetworkConfig
        ({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;

    }
       function getMainNetConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory MainNetConfig = NetworkConfig ({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return MainNetConfig;
       }

       function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory){
        if (activeNetworkConfig.priceFeed != address (0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMAL, INITIAL_ANSWER);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
}
}
