# Defi

[DefiLlama](https://defillama.com/) is the largest TVL aggregator for DeFi (Decentralized Finance)  
DeFi Llama demonstrates the size of various DeFi protocols by ranking them by Total Value Locked (TVL). Some of the biggest include:

**Lido:** Liquid Staking platform. Liquid staking provides the benefits of traditional staking while unlocking the value of staked assets for use as collateral.

**MakerDAO:** Collateralized Debt Position (CDP) protocol for making stablecoins.  

[**AAVE:**](https://aave.com/) Borrowing/Lending protocol, similar to a decentralized bank.  

**Curve Finance:** Decentralized Exchange (DEX), specialized for working with stablecoins.

[**Uniswap:**](https://uniswap.org/) General purposes Decentralized Exchange for swapping tokens and various digital assets.

### MEV
concept of Miner/Maximal Extractable Value (MEV).  
At a very high-level, MEV is the process by which a node validator or miner orders the transactions of a block they're validating in such as way as to benefit themselves or conspirators.  

There are many teams and protocols working hard to mitigate the effects of MEV advantages, to get deep into DeFi read through and understand the content on [flashbots.net's New to MEV guide](https://docs.flashbots.net/new-to-mev). This content is both an entertaining way to learn about a complex concept and extremely eye-opening to the dangers MEV represents in the DeFi space.

---

# StableCoins, but actually

## What are stablecoins?

**ACTUALLY:** A STABLECOIN IS A CRYPTO ASSET WHOSE BUYING POWER FLUCTUATES VERY LITTLE REALTIVE TO THE REST OF THE MARKET.

Investopedia describes stablecoins as - Cryptocurrencies the value of which is pegged, or tied, to that of another currency, commodity or financial instrument.  
But Stablecoin is more than that!    

A `stablecoin` is a crypto asset whose buying power stays relatively stable.

A simple example of unstable buying power is `Bitcoin (BTC)`.  

## Why StableCoins

Society requires an everyday stable currency in order to fulfill the 3 functions of money:

1. Storage of Value

2. Unit of Account

3. Medium of Exchange

**Storage of Value:** Money retains value over time, allowing individuals to save and defer consumption until a later date. This function is crucial because it means money can be saved, retrieved, and spent in the future without losing its purchasing power (assuming stable inflation).

**Unit of Account:** Money provides a standard numerical unit of measurement for the market value of goods, services, and other transactions. It enables consumers and businesses to make informed decisions because prices and costs can be compared. This function helps in record-keeping and allows for the consistent measurement of financial performance.

**Medium of Exchange:** Money serves as an intermediary in trade, making transactions more efficient than bartering. In a barter system, two parties must have exactly what the other wants, known as a double coincidence of wants. Money eliminates this issue by providing a common medium that everyone accepts in exchange for goods and services.

In Web3, we need a Web3 version of this. This is where stablecoins shine. Assets like BTC and ETH do well as stores of value and as mediums of exchange, but fail as a reasonable unit of account due to their buying power volatility.

## Categories and Properties
When someone searches for types of stablecoins you'll often see them grouped into common buckets:

* Fiat-Collateralized

* Crypto-Collateralized

* Commodity-Collateralized

* Algorithmic

This again is a serviceable understanding of stablecoin categories, but the reality is much more complicated. I prefer to categorize stablecoins as:

1. Relative Stability - Pegged/Anchored or Floating

2. Stability Method - Governed or Algorithmic

3. Collateral Type - Endogenous or Exogenous

**Relative Stability:** Something is only stable relative to its value in something else. The most common type of `stablecoins` are `pegged` or `anchored` `stablecoins`. Their value is determined by their `anchor` to another asset such as the US Dollar. `Tether`, `DAI` and `USDC` are examples of stablecoins which are pegged to USD.

These stablecoins general possess a mechanism which makes them nearly interchangable with the asset to which they're pegged. For example, USDC claims that for each USDC minted, there's an equivalent US Dollar (or equal asset) in a bank account somewhere.

DAI on the other hand, uses permissionless over-colleralization.  

As mentioned, stablecoins don't have to be pegged. Even when pegged to a relatively stable asset like the US Dollar, forces such as inflation can reduce buying power over time. A proposed solution (that's albeit much more complex) are floating value stablecoins, where, through clever math and algorithms the buying power of the asset is kept stable overtime without being anchors to another particular asset.  
If you're interested in learning more, you to check out this [Medium Article on RAI](https://medium.com/intotheblock/rai-a-free-floating-stablecoin-that-actually-works-d9efbbca94c0), a free-floating stablecoin.  

**Stability Method:** Another major delineating factor of `stablecoins` is the stability method employed. This is the mechanism that keeps the asset's value stable. How is the asset pegged to another?  

This usually works by having the stablecoin mint and burn in very specific ways and is usually determined by who or what is doing the mint/burn.  

This process can exist on a spectrum between governed and algorithmic.

* **Governed:** This denotes an entity which ultimately decides if stablecoins in a protocol should be minted or burned. This could something very centralized and controller, like a single person, or more democratic such as governed via DAO. Governed stablecoins are generally considered to be quite centralized. This can be tempered by DAO participations, 

   * Examples of governed stablecoins include:

     * USDC

     * Tether

     * USDT

* **Algorithmic:** Conversely, algorithmic stablecoins maintain their stability through a permissionless algorithm with no human intervention. consider a stablecoin like DAI as being an example of an algorithmic stablecoin for this reason. All an algorithmic stablecoin is, is one which the minting and burning is dictated by autonomous code.

    * Examples of algorithmic stablecoins include:

      * DAI

      * FRAX

      * RAI

      * UST - RIP, we'll talk more about this later.


DAI is a bit of a hybrid where a DAO determines things like interest rates, but the minting/burning is handled autonomously. USDC is an example of something very centralized, with a single governing body, where as UST was almost purely algorithmic.  

[The Dirt Roads blog](https://dirtroads.substack.com/p/-40-pruning-memes-algo-stables-are) has a great article and visualizations outlining these differences in detail and where popular assets fall on this spectrum.  

![see the image](https://substackcdn.com/image/fetch/$s_!BqI5!,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F671a2247-8c26-4d39-be06-ba834ea7b2a3_1913x1321.png)

>❗ **_NOTE_:**
> Dirt Roads uses `Dumb` as the opposite of algorithmic, instead of governed.


You'll notice that most Fiat-Collateralized assets are more governed, as you'll often need a centralized entity to onramp the fiat into the blockchain ecosystem.

In summary:

* Algorithmic Stablecoins use a transparent math equation or autonomously executed code to mint and burn tokens

* Governed Stablecoins mint and burn tokens via human interaction/decision


**Collateral Type:** When we refer to collateral, we're referring to the asset backing the token, giving it its value. USDC is collateralized by the US Dollar, making one USDC worth one USD. DAI is collateralized by many different assets, you can deposit ETH to mint DAI, among many currencies. UST .. In a round about way was collateralized by LUNA.  

These are examples of exogenous and endogenous types of collateral.

* **Exogenous:** Collateral which originates from outside of a protocol.

* **Endogenous:** Collateral which originates from within a protocol

The easiest way to determine in which category a stablecoin's collateral falls is the ask this question:

*If the stablecoin fails, does the underlying collateral also fail?*

Yes == Endogenous

No == Exogenous  

If USDC Fails, the US Dollar isn't going to be affected. USDC is an example of Exogenous collateral. DAI is another example of this, the value of ETH won't be affected by the failure of the DAI protocol.

UST/LUNA on the other hand is an example of Endogenous collateral. When UST failed, LUNA also failed causing the protocol to bleed $40 billion dollars.  

Other good questions to ask include:

*What the collateral created for the purpose of being collateral?*
or
*Does the protocol own the issuance of the underlying collateral?*

The risk exists with endogenously collateralized protocols because their value essentially comes from .. nothing or is self-determined at some point in development.

Endogenously collateralized stablecoins don't have a great track record - TerraLUNA and UST was a catastrophic event that wiped billions out of DeFi. So, why would anyone want to develop a stablecoin like this?

Generally the response is Scale/Capital Efficiency.  

When a protocol is entirely exogenously collateralized, its marketcap is limited by the collateral it can onboard into the ecosystem. If no collateral needs to be onboarded into the protocol, scaling becomes easier much faster.

Now, many endogenous stablecoins can be traced back to a single [paper by Robert Sams](https://blog.bitmex.com/wp-content/uploads/2018/06/A-Note-on-Cryptocurrency-Stabilisation-Seigniorage-Shares.pdf). In this paper he discusses how to build an endogenously collateralized stablecoin using a seigniorage shares model.

### Top Stablecoins

**DAI**

DAI is:

* Pegged
* Algorithmic
* Exogenously Collateralized

Effectively how DAI works is, a user deposits some form of crypto collateral, such as ETH, and based on the current value of that collateral in US Dollars, some value of DAI is minted the user. It's only possible to mint less DAI than the value of collateral a user has deposited. In this way the stablecoin is said to be over-collateralized.

>❗ **_NOTE_**
> DAI also has an annual stability fee on deposited collateral ~2%

When a user wants to redeem their collateral, DAI must be deposited back into the protocol, which then burns the deposited DAI and released the appropriate amount of collateral.

The combination of a stability fee and over-collateralization is often referred to as a `collateralized debt position`.

*What happens if stability fees can't be paid, or the value of our collateral decreases?*

If this happens, a user is at risk of liquidation. This is the mechanism through which the system avoids becoming under-collateralized.  

The fundamental question arises:  

*Why would I pay a fee to mint this stablecoin?*
Coming to this....  

**USDC**

USDC is:

* Pegged
* Governed
* Exogenous

USDC is backed by real-world dollars. Simple as that.

**Terra USD(UST)/Terra LUNA**

This situation has become infamous now, but there's lots we can learn from this disaster to prevent it in the future.

UST was:

* Pegged
* Algorithmic
* Endogenous

What we know about stablecoins now should shed some light on what happened to UST/LUNA. Because UST was backed by LUNA, when UST lost it's peg (usually through a massive influx of trading), it's underlying collateral (LUNA) became less attractive to hold .. which caused UST to lose more value. And thus the circling of the drain began until the asset was all but wiped out.

**FRAX**

FRAX is:

* Pegged
* Algorithmic
* Hybrid

Endogenously collateralize stablecoins are so attractive because they do scale quickly. More recent projects, like FRAX, have tried to thread this needle of hybrid collateralization to find an optimal balance.

**RAI**

RAI is:

* Floating
* Algorithmic
* Exogenous

RAI is one of the few examples of a floating stablecoin. The protocol focuses on 3 things

* minimal governance, achieved through algorithmic mechanisms of stabilization

* Being Floating, such that it's value isn't derived by being tied to another asset

* Only using ETH as collateral

You can read more about the mechanisms of RAI [here](https://medium.com/intotheblock/rai-a-free-floating-stablecoin-that-actually-works-d9efbbca94c0).  

What do stablecoins really do?
Maybe we start with asking: Which is the best stablecoin?

The answer to this may come down to about whom we're speaking.

Stablecoins, which are centralized, such as USDC, Tether etc, may not really fit the ethos of decentralization in Web3, it might be preferred to have a degree of decentrality.

By the same token (pun intended), algorithmic stablecoins may be intimidating to the average user and the associated fees may be non-starters.

At the end of the day every stablecoin protocol has it's trade-offs and what's right for one person or circumstance may not be right for another.

Now, here's something that may give you whiplash:

*The stablecoin preferred by the average user, is likely much less important than those preferred by the 'rich whales' in the space*

### Think about it!

Say you want to accumulate a tonne of ETH, you've solve everything you own and put it all into ETH, but you want more. How do you accomplish this?

By depositing ETH as collateral into a stablecoin protocol, you're able to mint the stablecoin, and sell it for more ETH. This becomes beneficial when you consider leveraged trading.

**Leveraged Trading:** Leveraged trading involves using borrowed capital to increase the potential return on investment. This strategy can magnify both gains and losses, allowing for potentially higher profits but also increased risk.

This usecase for high-value investing is so pervasive that it's often outlined by platforms as a primary reason to mint, to maximize your position on a crypto asset.

So, to summarize a bit:

*Why are stablecoins used?*

* To execute the 3 functions of money.

*Why are stablecoins minted?*

* Investors like to make leveraged bets.

---

# Advance Testing: Fuzz Testing

See this video on [fuzz testing](https://youtu.be/juyY-CTolac?si=-JSPpTTjYzxNIQ-u)

While developing a protocol and writing tests, we should always be thinking "What are my protocol invariants?". Having these clearly defined will make advanced testing easier for us to configure.   

Fuzz Testing is when you supply random data to a system in an attempt to break it. Let us take an example:  

```solidity
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
​
contract MyContract {
    uint256 public shouldAlwaysBeZero = 0;
    uint256 hiddenValue = 0;
​
    function doStuff(uint256 data) public {
        if (data == 2){
            shouldAlwaysBeZero = 1;
        }
    }
}
```
In the above shouldAlwaysBeZero == 0 is our invariant, the property of our system that should always hold. By fuzz testing this code, our test supplies our function with random data until it finds a way to break the function, in this case if 2 was passed as an argument our invariant would break. This is a very simple example, but you could imagine the complexity scaling quickly.  

Simple unit test for the above might look something like:
```solidity
function testIAlwaysGetZero() public {
    uint256 data = 0;
    myContract.doStuff(data);
    assert(myContract.shouldAlwaysBeZero() == 0);
}
```
The limitation of the above should be clear, we would have the assign data to every value of uin256 in order to assure our invariant is broken... That's too much.

Instead we invoke fuzz testing by making a few small changes to the test syntax.  

```solidity
function testIAlwaysGetZero(uint256 data) public {
    myContract.doStuff(data);
    assert(myContract.shouldAlwaysBeZero() == 0);
}
```
That's it. Now, if we run this test with Foundry, it'll throw random data at our function as many times as we tell it to, until it breaks our assertion.  

The fuzzer isn't using truly random data, it's pseudo-random, and how your fuzzing tool chooses its data matters! Echidna and Foundry are both solid choices in this regard.  

Important properties of the fuzz tests we configure are its runs and depth.

**Runs:** How many random inputs are provided to our test  

However, we can customize how many attempts the fuzzer makes within our foundry.toml by adding a section like:  

```Toml
[fuzz]
runs = 1000
```

## Stateful Fuzz Testing

Take the following contract for example:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
​
contract CaughtWithTest {
    uint256 public shouldAlwaysBeZero = 0;
    uint256 private hiddenValue = 0;
​
    function doStuff(uint256 data) public {
        // if (data == 2) {
        //     shouldAlwaysBeZero = 1;
        // }
        if (hiddenValue == 7) {
            shouldAlwaysBeZero = 1;
        }
        hiddenValue = data;
    }
}
```
In this situation, even if we mitigate the previous issue spotted by our fuzz tester, another remains. We can see in this simple example that if hiddenValue == 7, then our invariant is going to be broken. The problem however is that two subsequent function calls must be made for this to be the case. First, the function must be called wherein data == 7, this will assign 7 to hiddenValue. Then the function must be called again in order for the conditional to break our invariant.

What this is describing is the need for our test to account for changes in the state of our contract. This is known as Stateful Fuzzing. Our fuzz tests til now have been Stateless, which means the state of a run is discarded with each new run.

Stateful Fuzzing allows us to configure tests wherein the ending state of one run is the starting state of the next.

### Stateful Fuzz Test Setup

In order to run stateful fuzz testing in Foundry, it requires a little bit of setup. First, we need to import StdInvariant.sol and have our contract inherit this.

```solidity
// SPDX-License-Identifier: None
pragma solidity ^0.8.13;
​
import {CaughtWithTest} from "src/MyContract.sol";
import {console, Test} from "forge-std/Test.sol";
import{StdInvariant} from "forge-std/StdInvariant.sol";
​
contract MyContractTest is StdInvariant, Test {
    CaughtWithTest myContract;
​
    function setUp() public {
        myContract = new CaughtWithTest();
    }
}
```

The next step is, we need to set a target contract. This will be the contract Foundry calls random functions on. We can do this by calling targetContract in our setUp function.

```solidity
contract NFT721Test is StdInvariant, Test {
    CaughtWithTest myContract;
​
    function setUp() public {
        myContract = new CaughtWithTest();
        targetContract(address(myContract));
    }
}
```
Finally, we just need to write our invariant, we must use the keywords invariant, or fuzz to begin this function name, but otherwise, we only need to declare our assertion, super simple.  

```solidity
function invariant_testAlwaysReturnsZero() public view {
    assert(myContract.shouldAlwaysBeZero() == 0);
}
```
Now, if our fuzzer ever calls our doStuff function with a value of 7, hiddenValue will be assigned 7 and the next time doStuff is called, our invariant should break.  

## Handler Fuzz Tests

Navigate to the [Fuzz Testing section](https://book.getfoundry.sh/forge/fuzz-testing) in the Foundry Docs to read more on advanced fuzz testing within this framework.

In our previous fuzz testing examples, we were demonstrating "open testing". This kinda gives control to the framework and allows it to call any functions in a contract randomly, in a random order.

More advanced fuzz tests implement [handler based testing](https://book.getfoundry.sh/forge/invariant-testing#handler-based-testing).  

Larger protocols will have so many functions available to them that it's important to narrow the focus of our tests for a better chance to find our bugs. This is where handlers come in. They allow us to configure aspects of a contract's state before our tests are run, as well as set targets for the test functions to focus on.  

Handler based tests route our frameworks function calls through our handler, allowing us to configure only the functions/behaviour we want it to perform, filtering out bad runs from our tests.

### Example setup of fuzz testing

The first thing we want to do to prepare our stateful fuzzing suite is to configure some of the fuzzer options in our foundry.toml.  

```Toml
[invariant]
runs = 128
depth = 128
fail_on_revert = false
```
Adding the above to our foundry.toml will configure our fuzz tests to attempt `128 runs` and make `128 calls` in each run (depth).

Next, create the directory test/fuzz. We'll need to create 2 files within this folder, `InvariantsTest.t.sol` and `Handler.t.sol`.

`InvariantsTest.t.sol` will ultimately hold the tests and the invariants that we assert, while the handler will determine how the protocol functions are called. for example in this StableCoin project, if our fuzzer makes a call to `depositCollateral` without having _minted any collateral_, it's kind of a wasted run. We can filter these with an adequate handler configuration.  

Before writing a single line of our invariant tests we need to ask the question:

*What are the invariants of my protocol?*  
We need to ascertain which properties of our system must always hold.

*fail_on_revert* option determines whether the test suite should fail if a revert occurs during the execution of a handler function.  
`fail_on_revert` set to true should reveal what's causing our reverts.  

>❗ IMPORTANT
>Be careful when configuring fail_on_revert to be true _or false. Sometimes we risk narrowing our tests too much with our Handler that we miss edge cases.