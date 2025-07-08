// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract DSCEngineTest is Test {
    DecentralizedStableCoin dsc;
    DSCEngine dsce;
    DeployDSC deployer;
    HelperConfig helper;
    address ethUsdPriceFeed;
    address weth;
    address btcUsdPriceFeed;
    address wbtc;

    uint256 public constant LOCAL_CHAIN_ID = 31337;
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 10 ether;
    address genius = makeAddr("Genius");

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dsce, helper) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc,) = helper.activeNetworkConfig();
        ERC20Mock(weth).mint(genius, STARTING_ERC20_BALANCE);
        ERC20Mock(wbtc).mint(genius, STARTING_ERC20_BALANCE);
    }

    modifier skipFork() {
        if (block.chainid != LOCAL_CHAIN_ID) {
            return;
        }
        _;
    }

    function testGetUsdValue() public view skipFork {
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

    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function testRevertIfNumberOfPriceFeddAddressesDontMatchNumberOfTokenAddresses() public {
        tokenAddresses.push(weth);
        priceFeedAddresses.push(ethUsdPriceFeed);
        priceFeedAddresses.push(btcUsdPriceFeed);
        vm.expectRevert(DSCEngine.DSCEngine__NumberOfTokenAddressShouldMatchNumberOfPriceFeedAddresses.selector);
        new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));
    }

    function testGetTokenAmountFromUsd() public view {
        uint256 usdAmountInWei = 100 ether;
        uint256 expectedAmount = 0.1 ether;
        uint256 actualWeth = dsce.getTokenAmountFromUsd(weth, usdAmountInWei);
        assertEq(expectedAmount, actualWeth);
    }

    function testDepositCollateralModifiers() public {
        vm.expectRevert(DSCEngine.DSCEngine__amountShouldBeMoreThanZero.selector);
        dsce.depositCollateral(weth, 0);
        vm.expectRevert(DSCEngine.DSCEngine__tokenNotSupported.selector);
        dsce.depositCollateral(address(0), 1);
    }

    modifier depositedCollateral(address tokenCollateralAddress) {
        vm.startPrank(genius);
        // we need to approve dsce to spend(or deposit) weth a certain amount
        ERC20Mock(tokenCollateralAddress).approve(address(dsce), AMOUNT_COLLATERAL);
        dsce.depositCollateral(tokenCollateralAddress, AMOUNT_COLLATERAL);
        vm.stopPrank();
        _;
    }

    function testDepositCollateralAndGetAccountInfo() public depositedCollateral(weth) {
        (uint256 totalDscMinted, uint256 totalCollateralInUsd) = dsce.getAccountInformation(genius);
        uint256 expectedDepositCollateral = dsce.getTokenAmountFromUsd(weth, totalCollateralInUsd);
        assertEq(totalDscMinted, 0);
        assertEq(expectedDepositCollateral, AMOUNT_COLLATERAL);
    }

    function testDepositCollateralEmit() public {
        vm.startPrank(genius);
        ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);
        vm.expectEmit(true, true, false, true, address(dsce));
        emit DSCEngine.CollateralDeposited(genius, weth, AMOUNT_COLLATERAL);
        dsce.depositCollateral(weth, AMOUNT_COLLATERAL);
        vm.stopPrank();
    }

    function testMintDsc() public depositedCollateral(weth) {
        vm.prank(genius);
        vm.expectRevert(abi.encodeWithSelector(DSCEngine.DSCEngine__BreaksHealthFactor.selector, 833333333333333333)); //Its just calculated value
        dsce.mintDSC(6e21); //6e21 == 6000e18 is the point where healthfactor breaks when AMOUNT_COLLATERAL is deposited
    }

    function testRedeemCollateral() public depositedCollateral(weth) {
        vm.startPrank(genius);
        dsce.mintDSC(1000e18);
        vm.expectRevert(abi.encodeWithSelector(DSCEngine.DSCEngine__BreaksHealthFactor.selector, 5e17));
        dsce.redeemCollateral(weth, 9 ether);
        console.log(dsce.getHealthFactor());
        vm.stopPrank();
    }

    function testBurnDsc() public depositedCollateral(weth) {
        vm.startPrank(genius);
        dsce.mintDSC(2 ether);
        dsc.approve(address(dsce), 1 ether);
        dsce.burnDSC(1 ether);
        vm.stopPrank();
    }

    function testGetAccountCollateralValueInUsd() public depositedCollateral(weth) depositedCollateral(wbtc) {
        vm.prank(genius);
        assertEq(dsce.getAccountCollateralValueInUsd(genius), 30000e18);
    }

    function testCheckIfCanLiquidate() public depositedCollateral(weth) {
        vm.prank(genius);
        dsce.mintDSC(2 ether);
        vm.expectRevert(DSCEngine.DSCEngine__HealthFactorIsOk.selector);
        dsce.liquidate(weth, genius, 1 ether);
    }

    function testLiquidateWorksEnd_to_End() public depositedCollateral(weth) {
        /**
         *
         * 1. Genius deposits 10 ETH (done by the modifier) and mints 4 000 DSC
         *    → health‑factor ≈ 1.25 while price is $1 000.
         *
         */
        vm.startPrank(genius);
        dsce.mintDSC(4_000e18);
        vm.stopPrank();

        /**
         *
         * 2. ETH price crashes from $1 000 -> $700,
         *    making Genius under‑collateralised (HF ≈ 0.875 < 1).
         *
         */
        int256 newPrice = 700 * 1e8; // Chainlink prices have 8 decimals
        MockV3Aggregator(ethUsdPriceFeed).updateAnswer(newPrice);

        vm.prank(genius);
        uint256 healthFactorBefore = dsce.getHealthFactor();
        assertLt(healthFactorBefore, 1e18); // must now be liquidatable

        /**
         *
         * 3. Create a liquidator that has DSC to burn.
         *
         */
        address liquidator = makeAddr("Liquidator");
        ERC20Mock(weth).mint(liquidator, STARTING_ERC20_BALANCE);

        vm.startPrank(liquidator);
        // deposit 10 ETH so the liquidator is always solvent
        ERC20Mock(weth).approve(address(dsce), STARTING_ERC20_BALANCE);
        dsce.depositCollateral(weth, STARTING_ERC20_BALANCE);

        // mint 2 000 DSC – we’ll burn these to cover Genius’ debt
        dsce.mintDSC(2_000e18);
        dsc.approve(address(dsce), 2_000e18);

        uint256 liquidatorWethBefore = ERC20Mock(weth).balanceOf(liquidator);
        (uint256 geniusDebtBefore,) = dsce.getAccountInformation(genius);

        /**
         *
         * 4. Perform the liquidation.
         *
         */
        dsce.liquidate(weth, genius, 2_000e18);
        vm.stopPrank();

        /**
         *
         * 5. Assertions
         *
         */
        // borrower’s debt shrank by exactly debtToCover
        (uint256 geniusDebtAfter,) = dsce.getAccountInformation(genius);
        assertEq(geniusDebtAfter, geniusDebtBefore - 2_000e18);

        // liquidator received principal + 10 % bonus collateral
        uint256 liquidatorWethAfter = ERC20Mock(weth).balanceOf(liquidator);
        assertGt(liquidatorWethAfter, liquidatorWethBefore);

        // borrower’s health‑factor improved and is > 1
        vm.prank(genius);
        uint256 healthFactorAfter = dsce.getHealthFactor();
        assertGt(healthFactorAfter, 1e18);
        assertGt(healthFactorAfter, healthFactorBefore);
    }
}
