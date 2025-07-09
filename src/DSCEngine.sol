// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {OracleLib} from "./libraries/OracleLib.sol";
/**
 * @title DSCEngine
 * @author Akshat odiya
 *
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg at all times.
 * This is a stablecoin with the properties:
 * - Exogenously Collateralized
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was backed by only WETH and WBTC.
 *
 * Our DSC system should always be "overcollateralized". At no point, should the value of
 * all collateral < the $ backed value of all the DSC.
 *
 * @notice This contract is the core of the Decentralized Stablecoin system. It handles all the logic
 * for minting and redeeming DSC, as well as depositing and withdrawing collateral.
 * @notice This contract is based on the MakerDAO DSS system
 */

// You can use commad `forge inspet DSCEngine methods` to get all the functions that that contract have with their function selectors

contract DSCEngine is ReentrancyGuard {
    error DSCEngine__amountShouldBeMoreThanZero();
    error DSCEngine__tokenNotSupported();
    error DSCEngine__NumberOfTokenAddressShouldMatchNumberOfPriceFeedAddresses();
    error DSCEngine__TransferFailed();
    error DSCEngine__BreaksHealthFactor(uint256);
    error DSCEngine__MintFailed();
    error DSCEngine__HealthFactorIsOk();
    error DSCEngine__HealthFactorNotImproved();

    using OracleLib for AggregatorV3Interface;

    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; //%200 collaterised
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;
    uint256 private constant LIQUIDATOR_BONUS = 10; //%10 bonus

    mapping(address tokenAddress => address priceFeed) s_tokenAddressToPriceFeed;
    mapping(address user => mapping(address token => uint256 amount)) s_collateralDeposited;
    mapping(address user => uint256 amount) private s_DSCMintedToUser;
    address[] private s_collateralTokens;

    DecentralizedStableCoin private immutable i_dsc;

    event CollateralDeposited(address indexed user, address indexed tokenAddress, uint256 amountDeposited);
    event CollateralRedeemed(
        address indexed redeemedFrom, address indexed redeemedTo, address indexed token, uint256 amount
    );

    modifier isAllowedToken(address token) {
        if (s_tokenAddressToPriceFeed[token] == address(0)) {
            revert DSCEngine__tokenNotSupported();
        }
        _;
    }

    modifier moreThanZero(uint256 amount) {
        if (amount <= 0) {
            revert DSCEngine__amountShouldBeMoreThanZero();
        }
        _;
    }

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__NumberOfTokenAddressShouldMatchNumberOfPriceFeedAddresses();
        }
        uint256 upto = tokenAddresses.length;
        for (uint256 i = 0; i < upto; i++) {
            s_tokenAddressToPriceFeed[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }
        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    // This function will allow depositing collateral and miniting DSC in one go
    function depositCollateralAndMintDSC(
        address tokenCollateralAddress,
        uint256 amountCollateral,
        uint256 amountDscToMint
    ) external {
        depositCollateral(tokenCollateralAddress, amountCollateral);
        mintDSC(amountDscToMint);
    }

    /**
     * follows CEI Pattern
     * @param tokenCollateralAddress The address of the token to deposit as collateral
     * @param amountCollateral The amount of collateral to deposit
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        public
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDSC(address tokenCollateralAddress, uint256 amountCollateral, uint256 amountDscToBurn)
        external
    {
        redeemCollateral(tokenCollateralAddress, amountCollateral);
        burnDSC(amountDscToBurn);
    }

    /*
     * Why we need to declare two redeemCollateral(`redeemCollateral` and `_redeemCollateral`)
     * The `redeemCollateral` function can be called by anyone
     * And `_redeemCollateral` can only be called as private function, it has Restricted call.
     * `_redeemCollateral` can redeem from anyone to anyone(caller)
     * Thats why it is dangerous to have a direct access to _redeemCollateral
     */
    function redeemCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        public
        moreThanZero(amountCollateral)
        nonReentrant
    {
        _redeemCollateral(msg.sender, msg.sender, tokenCollateralAddress, amountCollateral);
    }

    /*
     * Why we need to declare two burnDSC(`burnDSC` and `_burnDSC`)
     * The `burnDSC` function can be called by anyone
     * And `burnDSC` can only be called as private function, it has Restricted call.
     * `_burnDSC` can burn from anyone to anyone(caller)
     * Thats why it is dangerous to have a direct access to _burnDSC
     */
    function burnDSC(uint256 amount) public moreThanZero(amount) {
        _burnDSC(msg.sender, msg.sender, amount);
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    /**
     * Follows CEI pattern
     * @param amountDscToMint The amount of decentralised stablecoin to mint
     * @notice user must have more collteral than the minimum threshold
     */
    function mintDSC(uint256 amountDscToMint) public moreThanZero(amountDscToMint) nonReentrant {
        s_DSCMintedToUser[msg.sender] += amountDscToMint;
        _revertIfHealthFactorIsBroken(msg.sender);
        bool minted = i_dsc.mint(msg.sender, amountDscToMint);
        if (!minted) {
            revert DSCEngine__MintFailed();
        }
    }

    /*
     * @param collateral: The ERC20 token address of the collateral you're using to make the protocol solvent again.
     * This is collateral that you're going to take from the user who is insolvent.
     * In return, you have to burn your DSC to pay off their debt, but you don't pay off your own.
     * @param user: The user who is insolvent. They have to have a _healthFactor below MIN_HEALTH_FACTOR
     * @param debtToCover: The amount of DSC you want to burn to cover the user's debt.
     *
     * @notice: You can partially liquidate a user.
     * @notice: You will get a 10% LIQUIDATION_BONUS for taking the users funds.
     * @notice: This function working assumes that the protocol will be roughly 150% overcollateralized in order for this
     * to work.
     * @notice: A known bug would be if the protocol was only 100% collateralized, we wouldn't be able to liquidate
     * anyone.
     * For example, if the price of the collateral plummeted before anyone could be liquidated.
     */

    /*
     * Users will deposit collateral greater in value than the DSC they mint. 
     * If their collateral value falls such that their position becomes under-collateralized, another user can liquidate the position,
     * by paying back/burning the DSC in exchange for the positions collateral. 
     * This will net the liquidator the difference in the DSC value and the collateral value in profit as incentive for securing the protocol.
    */
    function liquidate(address tokenCollateralAddress, address user, uint256 debtToCover)
        external
        moreThanZero(debtToCover)
        nonReentrant
    {
        uint256 startingUserHealthFactor = _healthFactor(user);
        if (startingUserHealthFactor >= MIN_HEALTH_FACTOR) {
            revert DSCEngine__HealthFactorIsOk();
        }

        // We want to burn their DSC "debt"
        // And take their collateral
        // Bad User: $140 ETH, $100 DSC
        // debtToCover = $100
        // $100 of DSC = ??? ETH
        // 0.05 ETH Here
        // This is to calculate how much ETH will corresponds to how much DSC(we know DSC is pegged to US dollar i.e, 1 DSC = 1 USD)
        uint256 tokenAmountFromDebtToBeCovered = getTokenAmountFromUsd(tokenCollateralAddress, debtToCover);
        // And give them a 10% bonus
        // So we are giving the liquidator $110 of WETH for 100 Dsc
        uint256 bonusCollateral = (tokenAmountFromDebtToBeCovered * LIQUIDATOR_BONUS) / LIQUIDATION_PRECISION;

        uint256 totalCollateralToRedeem = tokenAmountFromDebtToBeCovered + bonusCollateral;

        // Give the collateral to liquidator(msg.sender) taking from who is getting liquidated(user)
        _redeemCollateral(user, msg.sender, tokenCollateralAddress, totalCollateralToRedeem);

        // Decrease the dsc of msg.sender(liquidator) to cover the dsc of who is getting liquidated(user)
        // So that liquidator get the collateral of user and maintining the rules of protocol of over-collaterlisation
        // And burn the dsc of user
        _burnDSC(user, msg.sender, debtToCover);

        uint256 endingUserHealthFactor = _healthFactor(user);
        if (endingUserHealthFactor <= startingUserHealthFactor) {
            revert DSCEngine__HealthFactorNotImproved();
        }
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function _getAccountInformation(address user)
        private
        view
        returns (uint256 totalDscMinted, uint256 totalCollateralInUsd)
    {
        totalDscMinted = s_DSCMintedToUser[user];
        totalCollateralInUsd = getAccountCollateralValueInUsd(user);
    }

    // Returns how close to liquidation a user is, if a user goes below 1, then they can get liquidated
    function _healthFactor(address user) private view returns (uint256) {
        (uint256 totalDscMinted, uint256 totalCollateralInUsd) = _getAccountInformation(user);
        if (totalDscMinted == 0) {
            return type(uint256).max; // No debt, so health factor is "infinite"
        }
        uint256 collateralAdjustedForThreshold = (totalCollateralInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return ((collateralAdjustedForThreshold * PRECISION) / totalDscMinted);
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {
        //1. check health factor, if they have enough collateral?
        //2. If not revert.
        if (_healthFactor(user) < MIN_HEALTH_FACTOR) {
            revert DSCEngine__BreaksHealthFactor(_healthFactor(user));
        }
    }

    function _redeemCollateral(address from, address to, address tokenCollateralAddress, uint256 amountCollateral)
        private
    {
        s_collateralDeposited[from][tokenCollateralAddress] -= amountCollateral;
        emit CollateralRedeemed(from, to, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transfer(to, amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function _burnDSC(address onBehalfOf, address dscFrom, uint256 amount) private moreThanZero(amount) {
        s_DSCMintedToUser[onBehalfOf] -= amount;
        bool success = i_dsc.transferFrom(dscFrom, address(this), amount);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
        i_dsc.burn(amount);
    }

    function getTokenAmountFromUsd(address tokenCollateralAddress, uint256 usdAmountInWei)
        public
        view
        returns (uint256)
    {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_tokenAddressToPriceFeed[tokenCollateralAddress]);
        (, int256 value,,,) = priceFeed.stalePriceCheck();
        return (usdAmountInWei * PRECISION) / (uint256(value) * ADDITIONAL_FEED_PRECISION);
    }

    function getAccountCollateralValueInUsd(address user) public view returns (uint256 totalValueInUsd) {
        // loop through each collateral token, get the amount they have deposited,
        // and map it to the price, to get the usd value
        uint256 upto = s_collateralTokens.length;
        for (uint256 i = 0; i < upto; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalValueInUsd += getUsdValue(token, amount);
        }
        return totalValueInUsd;
    }

    /*
     * The precision of both these values is going to be different, the amount passed to this function is expected to have 18 decimal places where as our price has only 8. 
     * To resolve this we'll need to multiple our price by 1e10. Once our precision matches, we can multiple this by our amount, then divide by 1e18 to return a reasonably formatted number for USD units.
     */
    function getUsdValue(address token, uint256 amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_tokenAddressToPriceFeed[token]);
        // The `value` Chainlink returns will have 8 decimal places i.e. value*1e8 and amount will be in wei i.e. amount*1e18
        // se we need to compensate the precision of both terms by muliplying value with ADDITIONAL_FEED_PRECISION
        // see here by clicking more details, https://docs.chain.link/data-feeds/price-feeds/addresses?page=1&testnetPage=1
        (, int256 value,,,) = priceFeed.stalePriceCheck();
        return ((uint256(value) * ADDITIONAL_FEED_PRECISION * amount) / PRECISION);
    }

    function getAccountInformation(address user)
        external
        view
        returns (uint256 totalDscMinted, uint256 totalCollateralInUsd)
    {
        (totalDscMinted, totalCollateralInUsd) = _getAccountInformation(user);
    }

    function getCollateralTokens() external view returns (address[] memory) {
        return s_collateralTokens;
    }

    function getCollateralBalanceOfUser(address user, address token) external view returns (uint256) {
        return s_collateralDeposited[user][token];
    }

    function getHealthFactor() external view returns (uint256) {
        return _healthFactor(msg.sender);
    }

    function getCollateralTokenPriceFeed(address token) external view returns (address) {
        return s_tokenAddressToPriceFeed[token];
    }
}
