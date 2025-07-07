# Project

The Decentralized Stablecoin protocol has 2 contracts at it's heart.

* **DecentralizedStableCoin.sol**

* **DSCEngine.sol**

DecentralizedStableCoin.sol is effectively a fairly simple ERC20 with a few more advanced features imported such as [ERC20Burnable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Burnable.sol) and OpenZeppelin's [Ownable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol) libraries.  

The real meat of this protocol can be found in DSCEngine.sol. DecentralizeStableCoin.sol is ultimately going to be controlled by this DSCEngine and most of the protocol's complex functionality is included within including functions such as:

* **depositCollateralAndMintDsc**

* **redeemCollateral**

* **burn**

* **liquidate**  


... and much more.  

In addition to all the source contracts, this protocol comes with a full test suite including `unit`, `fuzz` and `invariant` tests.

