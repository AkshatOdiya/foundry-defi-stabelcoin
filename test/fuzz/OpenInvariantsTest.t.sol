// What can be our invariants?
/*
 1. The total supply of DSC should be less than the total value of collateral
 2. Getter view functions should never revert 
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// import {StdInvariant} from "forge-std/StdInvariant.sol";
// import {Test, console} from "forge-std/Test.sol";
// import {DeployDSC} from "../../script/DeployDSC.s.sol";
// import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
// import {DSCEngine} from "../../src/DSCEngine.sol";
// import {HelperConfig} from "../../script/HelperConfig.s.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// contract OpenInvariantsTest is StdInvariant, Test {
//     DSCEngine dsce;
//     DeployDSC deployer;
//     DecentralizedStableCoin dsc;
//     HelperConfig helper;
//     address ethUsdPriceFeed;
//     address weth;
//     address btcUsdPriceFeed;
//     address wbtc;

//     function setUp() external {
//         deployer = new DeployDSC();
//         (dsc, dsce, helper) = deployer.run();
//         (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc,) = helper.activeNetworkConfig();

//         targetContract(address(dsce));
//     }

//     function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
//         uint256 totalSupply = dsc.totalSupply();
//         uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsce));
//         uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dsce));

//         uint256 wethValue = dsce.getUsdValue(weth, totalWethDeposited);
//         uint256 wbtcValue = dsce.getUsdValue(wbtc, totalWbtcDeposited);
//         assert(wethValue + wbtcValue >= totalSupply);
//     }
// }
