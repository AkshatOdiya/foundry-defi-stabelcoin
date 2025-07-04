// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract DSCEngineTest is Test {
    DecentralizedStableCoin dsc;
    DSCEngine dsce;
    DeployDSC deployer;
    HelperConfig helper;
    address ethUsdPriceFeed;
    address weth;

    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 10 ether;

    address genius = makeAddr("Genius");

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dsce, helper) = deployer.run();
        (ethUsdPriceFeed,, weth,,) = helper.activeNetworkConfig();
        ERC20Mock(weth).mint(genius, STARTING_ERC20_BALANCE);
    }

    function testGetUsdValue() public view {
        uint256 ethamount = 15e18;
        uint256 expectedUsd = 15000e18;
        uint256 actualUsd = dsce.getUsdValue(weth, ethamount);
        assertEq(expectedUsd, actualUsd);
    }

    function testRevertIfHealthFactorIsNotSatisfied() public {
        vm.prank(genius);
        vm.expectRevert(abi.encodeWithSelector(DSCEngine.DSCEngine__BreaksHealthFactor.selector, 0));
        dsce.mintDSC(50);
    }

    function testRevertsIfCollateralIsZero() public {
        vm.startPrank(genius);
        ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);
        vm.expectRevert(DSCEngine.DSCEngine__amountShouldBeMoreThanZero.selector);
        dsce.depositCollateral(weth, 0);
        vm.stopPrank();
    }
}
