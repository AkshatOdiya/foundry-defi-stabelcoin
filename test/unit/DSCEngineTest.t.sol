// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract DSCEngineTest is Test {
    DecentralizedStableCoin dsc;
    DSCEngine dsce;
    DeployDSC deployer;
    HelperConfig helper;
    address ethUsdPriceFeed;
    address weth;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dsce, helper) = deployer.run();
        (ethUsdPriceFeed,, weth,,) = helper.activeNetworkConfig();
    }

    function testGetUsdValue() public view {
        uint256 ethamount = 15e18;
        uint256 expectedUsd = 15000e18;
        uint256 actualUsd = dsce.getUsdValue(weth, ethamount);
        assertEq(expectedUsd, actualUsd);
    }
}
