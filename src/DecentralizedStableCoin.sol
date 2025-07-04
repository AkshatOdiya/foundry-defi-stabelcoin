// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20, ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DecentralizedStableCoin
 * @author Akshat Odiya
 * Collateral Type: Exogenous(BTC & ETH)
 * Miniting: Algorithmic
 * Relative Stability: Pegged to USD
 */
contract DecentralizedStableCoin is ERC20Burnable, Ownable {
    error DecentralizedStableCoin_AmountMustBeGreaterThanZero();
    error DecentralizedStableCoin_YourBalanceIsLesserThanTheAmountYouWantToBurn();
    error DecentralizedStableCoin_NotAllowToMintZeroAddress();

    constructor() ERC20("DecentralizedStableCoin", "DSC") Ownable(address(this)) {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert DecentralizedStableCoin_AmountMustBeGreaterThanZero();
        }
        if (balance < _amount) {
            revert DecentralizedStableCoin_YourBalanceIsLesserThanTheAmountYouWantToBurn();
        }
        super.burn(_amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert DecentralizedStableCoin_NotAllowToMintZeroAddress();
        }
        if (_amount <= 0) {
            revert DecentralizedStableCoin_AmountMustBeGreaterThanZero();
        }
        _mint(_to, _amount);
        return true;
    }
}
