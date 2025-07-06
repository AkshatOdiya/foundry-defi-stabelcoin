// What can be our invariants?
/*
 1. The total supply of DSC should be less than the total value of collateral
 2. Getter view functions should never revert 
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Test, console2} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Handler} from "./Handler.t.sol";

contract InvariantsTest is StdInvariant, Test {
    DSCEngine dsce;
    DeployDSC deployer;
    DecentralizedStableCoin dsc;
    HelperConfig helper;
    address ethUsdPriceFeed;
    address weth;
    address btcUsdPriceFeed;
    address wbtc;
    Handler handler;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, dsce, helper) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc,) = helper.activeNetworkConfig();
        handler = new Handler(dsce, dsc);
        targetContract(address(handler));
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply() external view {
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsce));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dsce));

        uint256 wethValue = dsce.getUsdValue(weth, totalWethDeposited);
        uint256 wbtcValue = dsce.getUsdValue(wbtc, totalWbtcDeposited);

        console2.log("weth value: ", wethValue);
        console2.log("wbtc value: ", wbtcValue);
        console2.log("total supply: ", totalSupply);
        console2.log("Times mint called: ", handler.s_timeMintHasBeenCalled());
        assert(wethValue + wbtcValue >= totalSupply);
    }

    function invariant_getterFunctionsShouldNotRevertNoMatterWhat() public view {
        dsce.getCollateralTokens();
    }
}
