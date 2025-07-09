// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract Handler is Test {
    DSCEngine dsce;
    DecentralizedStableCoin dsc;
    ERC20Mock weth;
    ERC20Mock wbtc;
    uint256 constant MAX_DEPOSIT_SIZE = type(uint96).max;
    uint256 public s_timeMintHasBeenCalled;
    address[] public s_usersWhoHaveDepositedCollateral;
    MockV3Aggregator public ethUsdPriceFeed;

    constructor(DSCEngine _dsce, DecentralizedStableCoin _dsc) {
        dsce = _dsce;
        dsc = _dsc;

        address[] memory collateralTokens = dsce.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);
        ethUsdPriceFeed = MockV3Aggregator(dsce.getCollateralTokenPriceFeed(address(weth)));
    }

    function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        // We need to use bound, so that we dont have unnecessary reverts
        amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);

        // Ensuring onyl valid collateral is deposited
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);

        // mint and approve!
        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(dsce), amountCollateral);

        dsce.depositCollateral(address(collateral), amountCollateral);
        vm.stopPrank();
        s_usersWhoHaveDepositedCollateral.push(msg.sender);
    }

    /*
     * We also need to consider, who is minting our DSC with respect to who has deposited collateral
     * We can account for this in our test by ensuring that the user doesn't attempt to mint more than the collateral they have deposited, 
     * otherwise we'll return out of the function. We'll determine the user's amount to mint by calling our getAccountInformation function.
     */
    function mintDsc(uint256 amountDscToMint, uint256 addressSeed) public {
        // Only the user who has deposited collateral can call mintDSC. otherwise the calls will be unnecessary.
        vm.assume(s_usersWhoHaveDepositedCollateral.length > 0);

        address sender = s_usersWhoHaveDepositedCollateral[addressSeed % s_usersWhoHaveDepositedCollateral.length];
        (uint256 totalDscMinted, uint256 totalCollateralInUsd) = dsce.getAccountInformation(sender);
        int256 maxDscToMint = (int256(totalCollateralInUsd) / 2 - int256(totalDscMinted));

        vm.assume(maxDscToMint > 0);

        amountDscToMint = bound(amountDscToMint, 1, uint256(maxDscToMint));

        vm.startPrank(sender);

        dsce.mintDSC(amountDscToMint);
        vm.stopPrank();
        s_timeMintHasBeenCalled++;
    }

    function redeemCollateralFromSeed(uint256 collateralSeed, uint256 amountCollateral) public {
        // Ensuring onyl valid collateral is deposited
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        uint256 maxCollateralToRedeem = dsce.getCollateralBalanceOfUser(address(collateral), msg.sender);

        // We need to use bound, so that we dont have unnecessary reverts
        amountCollateral = bound(amountCollateral, 0, maxCollateralToRedeem);

        /*
         * Instead of using if statement
         if(amountCollateral==0){
         return;
         }
         * We can use vm.assume like this
         */
        vm.assume(amountCollateral > 0);

        dsce.redeemCollateral(address(collateral), amountCollateral);
    }

    // Some update will be required in DSCEngine if the price of the collateral for too low
    // so leave this for now
    /*
    function updateCollateralPrice(uint96 newPrice) public {
        int256 newPriceInt = int256(uint256(newPrice));
        ethUsdPriceFeed.updateAnswer(newPriceInt);
    }
    */

    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return weth;
        } else {
            return wbtc;
        }
    }
}
