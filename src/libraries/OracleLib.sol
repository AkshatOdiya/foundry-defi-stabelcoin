// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title OracleLib
 * @author Akshat Odiya
 * @notice This library is used to check the Chainlink Oracle for stale data.
 * Taking a look at the Chainlink price feeds(https://docs.chain.link/data-feeds/price-feeds/addresses) available,
 * we can see that each of these feeds as a configured heartbeat. The heartbeat of a price feed represents
 * the maximum amount of time that can pass before the feed is meant to update, otherwise the price is said to be come stale.
 * If a price is stale, functions will revert, and render the DSCEngine unusable - this is by design.
 * We want the DSCEngine to freeze if prices become stale(not changing).
 *
 * So if the Chainlink network explodes and you have a lot of money locked in the protocol... too bad.
 */
library OracleLib {
    error Oracle__TimeOut();

    uint256 public constant TIMEOUT = 3 hours; // why 3 hours?, See the heartbeat in chainlink pricefeed. We have intentionally taken +2 hours

    function stalePriceCheck(AggregatorV3Interface priceFeed)
        public
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            priceFeed.latestRoundData();
        uint256 secondSince = block.timestamp - updatedAt;
        if (secondSince > TIMEOUT) revert Oracle__TimeOut();
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }
}
