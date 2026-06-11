# W3PI Deployment Notes

This document summarizes the official W3PI deployment configuration for BNB Smart Chain Mainnet.

## Network

```text
Network: BNB Smart Chain Mainnet
Chain ID: 56
Native gas token: BNB
```

## Official Deployed Contracts

### W3PI Core Contract

```text
Status: Deployed and source-code verified
Address: 0x2ba78a103318bd4e3db45186113527651bb8dcca
Deploy transaction: 0x61b95fac616ec11d733cf62e28c59e9f2c67f30bc79cd31941df7b352100510f
BscScan address page: https://bscscan.com/address/0x2ba78a103318bd4e3db45186113527651bb8dcca
BscScan deploy transaction: https://bscscan.com/tx/0x61b95fac616ec11d733cf62e28c59e9f2c67f30bc79cd31941df7b352100510f
```

### W3PIViewer Contract

```text
Status: Deployed and source-code verified
Address: 0xb1fEA36eAcCcF976e990f9d01f3768c9b9EC0e0B
Deploy transaction: 0xfa5c12c14bc462ef72271535e5a0af7bc77f08a3f97aa0285db96f3e8776de75
BscScan address page: https://bscscan.com/address/0xb1fEA36eAcCcF976e990f9d01f3768c9b9EC0e0B
BscScan deploy transaction: https://bscscan.com/tx/0xfa5c12c14bc462ef72271535e5a0af7bc77f08a3f97aa0285db96f3e8776de75
```

## PancakeSwap V2 Configuration

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

## Official Constructor Configuration

```text
pancakeRouter_:
0x10ED43C718714eb63d5aA57B78B54704E256024E

pancakeFactory_:
0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73
```

## Quote Token Whitelist

The quote token whitelist was fixed during W3PI core deployment.

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

## Deployment Status

```text
1. W3PI core contract deployed.
2. W3PI core contract source code verified on BscScan.
3. W3PIViewer contract deployed.
4. W3PIViewer contract source code verified on BscScan.
5. Official contract addresses published in CONTRACTS.md.
```

## Pending Operational Steps

```text
1. Add initial W3PI/WBNB liquidity.
2. Call createAndRegisterPair(WBNB) on the W3PI core contract.
3. Record the official W3PI/WBNB pair address.
4. Update CONTRACTS.md with the official pair address.
5. Update website and bot environment variables.
6. Test read-only viewer previews and core user flows.
7. Update BscScan token/project metadata and logo.
```

## Important Notes

The quote token whitelist is fixed during deployment.

The deployed protocol is intended to be ownerless. There is no post-deployment admin function intended to add or remove quote tokens, change fee parameters, mint admin supply, blacklist users, pause transfers, or upgrade the contract.

Always verify the final deployed contract addresses through the official website, this repository, and BscScan before interacting with the protocol.

## Disclaimer

This document is for deployment transparency only. It does not guarantee token value, liquidity, exchange listings, price appreciation, trading volume, or user profit.

W3PI is not affiliated with Pi Network, Pi Coin, or any other Pi-branded blockchain, company, foundation, or project.
