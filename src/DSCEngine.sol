// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
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

contract DSCEngine is ReentrancyGuard {
    error DSCEngine__amountShouldBeMoreThanZero();
    error DSCEngine__tokenNotSupported();
    error DSCEngine__NumberOfTokenAddressShouldMatchNumberOfPriceFeedAddresses();
    error DSCEngine__transferFailed();
    error DSCEngine__BreaksHealthFactor(uint256);
    error DSCEngine__MintFailed();

    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; //%200 collaterised
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1;

    mapping(address tokenAddress => address priceFeed) s_tokenAddressToPriceFeed;
    mapping(address user => mapping(address token => uint256 amount)) s_collateralDeposited;
    mapping(address user => uint256 amount) private s_DSCMintedToUser;
    address[] private s_collateralTokens;

    DecentralizedStableCoin private immutable i_dsc;

    event CollateralDeposited(address indexed user, address indexed tokenAddress, uint256 amountDeposited);

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

    function depositCollateralAndMintDSC() external {}

    /**
     * follows CEI Pattern
     * @param tokenCollateralAddress The address of the token to deposit as collateral
     * @param amountCollateral The amount of collateral to deposit
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine__transferFailed();
        }
    }

    function redeemCollateralForDSC() external {}

    function redeemCollateral() external {}

    function burnDSC() external {}

    /**
     * Follows CEI pattern
     * @param amountDscToMint The amount of decentralised stablecoin to mint
     * @notice user must have more collteral than the minimum threshold
     */
    function mintDSC(uint256 amountDscToMint) external moreThanZero(amountDscToMint) nonReentrant {
        s_DSCMintedToUser[msg.sender] += amountDscToMint;
        _revertIfHealthFactorIsBroken(msg.sender);
        bool minted = i_dsc.mint(msg.sender, amountDscToMint);
        if (!minted) {
            revert DSCEngine__MintFailed();
        }
    }

    function liquidate() external {}

    function getHealthFactor() external view {}

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

    function getUsdValue(address token, uint256 amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_tokenAddressToPriceFeed[token]);
        // The `value` Chainlink returns will have 8 decimal places i.e. value*1e8 and amount will be in wei i.e. amount*1e18
        // se we need to compensate the precision of both terms by muliplying value with ADDITIONAL_FEED_PRECISION
        // see here by clicking more details, https://docs.chain.link/data-feeds/price-feeds/addresses?page=1&testnetPage=1
        (, int256 value,,,) = priceFeed.latestRoundData();
        return ((uint256(value) * ADDITIONAL_FEED_PRECISION * amount) / PRECISION);
    }
}
