# W3PI Deployment Notes

This document summarizes the intended W3PI deployment configuration for BNB Smart Chain.

## Network

```text
Network: BNB Smart Chain Mainnet
Chain ID: 56
Native gas token: BNB
```

## PancakeSwap V2

```text
PancakeSwap V2 Router:
0x10ED43C718714eb63d5aA57B78B54704E256024E

PancakeSwap V2 Factory:
0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73
```

## Core Contract Constructor

The W3PI core contract constructor uses:

```solidity
constructor(
    address initialHolder,
    address pancakeRouter_,
    address pancakeFactory_,
    address[] memory quoteTokens_
)
```

## Intended Quote Tokens

```text
WBNB / BNB:
0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c

BTCB / BTC:
0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c

ETH:
0x2170ed0880ac9a755fd29b2688956bd959f933f8

USDT:
0x55d398326f99059ff775485246999027b3197955

USDC:
0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d

FDUSD:
0xc5f0f7b66764f6ec8c8dff7ba683102295e16409

SOL:
0x570a5d26f7765ecb712c0924e4de545b89fd43df

AVAX:
0x1ce0c2827e2ef14d5c4f29a091d735a204794041

ARB:
0x990e87719da2e5bb158a7e25d0c96618db888888
```

## Constructor Quote Token Array

```text
["0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c","0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c","0x2170ed0880ac9a755fd29b2688956bd959f933f8","0x55d398326f99059ff775485246999027b3197955","0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d","0xc5f0f7b66764f6ec8c8dff7ba683102295e16409","0x570a5d26f7765ecb712c0924e4de545b89fd43df","0x1ce0c2827e2ef14d5c4f29a091d735a204794041","0x990e87719da2e5bb158a7e25d0c96618db888888"]
```

## Recommended Deployment Order

```text
1. Deploy W3PI core contract.
2. Verify and publish W3PI core source code on BscScan.
3. Add initial W3PI/WBNB liquidity before registering the AMM pair.
4. Call createAndRegisterPair(WBNB).
5. Deploy W3PIViewer with the deployed W3PI core contract address.
6. Verify and publish W3PIViewer source code on BscScan.
7. Update official website and bot environment variables.
8. Test read-only viewer previews and core user flows.
```

## Important Notes

The quote token whitelist is fixed during deployment.

The deployed protocol is intended to be ownerless. There should be no post-deployment admin function to add or remove quote tokens, change fee parameters, mint admin supply, blacklist users, pause transfers, or upgrade the contract.

Always verify the final deployed contract addresses through the official website and BscScan before interacting with the protocol.

## Disclaimer

This document is for deployment transparency only. It does not guarantee token value, liquidity, exchange listings, price appreciation, or user profit.
