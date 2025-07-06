// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract Handler is Test {
    DSCEngine dsce;
    DecentralizedStableCoin dsc;
    ERC20Mock weth;
    ERC20Mock wbtc;
    uint256 constant MAX_DEPOSIT_SIZE = type(uint96).max;
    uint256 public s_timeMintHasBeenCalled;
    address[] public s_usersWhoHaveDepositedCollateral;

    constructor(DSCEngine _dsce, DecentralizedStableCoin _dsc) {
        dsce = _dsce;
        dsc = _dsc;

        address[] memory collateralTokens = dsce.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);
    }

    // redeem collateral <-

    function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);

        // mint and approve!
        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(dsce), amountCollateral);

        dsce.depositCollateral(address(collateral), amountCollateral);
        vm.stopPrank();
        s_usersWhoHaveDepositedCollateral.push(msg.sender);
    }

    function mintDsc(uint256 amountDscToMint, uint256 addressSeed) public {
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
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        uint256 maxCollateralToRedeem = dsce.getCollateralBalanceOfUser(address(collateral), msg.sender);
        amountCollateral = bound(amountCollateral, 0, maxCollateralToRedeem);
        vm.assume(amountCollateral > 0);

        dsce.redeemCollateral(address(collateral), amountCollateral);
    }

    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return weth;
        } else {
            return wbtc;
        }
    }
}
