# W3PI Contracts

W3PI is an ownerless Web3 + Pi themed BEP-20 protocol deployed on BNB Smart Chain Mainnet.

The protocol uses the mathematical Pi theme symbolically. W3PI is not affiliated with Pi Network, Pi Coin, or any other Pi-branded blockchain, company, foundation, or project.

## Official Deployment

### Network

```text
BNB Smart Chain Mainnet
Chain ID: 56
```

### W3PI Core Contract

```text
Status: Deployed and source-code verified
Address: 0x2ba78a103318bd4e3db45186113527651bb8dcca
Deploy transaction: 0x61b95fac616ec11d733cf62e28c59e9f2c67f30bc79cd31941df7b352100510f
BscScan: https://bscscan.com/address/0x2ba78a103318bd4e3db45186113527651bb8dcca
```

### W3PIViewer Contract

```text
Status: Deployed and source-code verified
Address: 0xb1fEA36eAcCcF976e990f9d01f3768c9b9EC0e0B
Deploy transaction: 0xfa5c12c14bc462ef72271535e5a0af7bc77f08a3f97aa0285db96f3e8776de75
BscScan: https://bscscan.com/address/0xb1fEA36eAcCcF976e990f9d01f3768c9b9EC0e0B
```

## Repository Structure

```text
contracts/W3PI_Core.sol
contracts/W3PIViewer.sol

SECURITY.md
DEPLOYMENT.md
CONTRACTS.md

docs/DISCLAIMER.md
docs/VERIFICATION.md
```

## Repository Documents

* [CONTRACTS.md](CONTRACTS.md) - Official W3PI contract address registry
* [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment configuration and quote token whitelist
* [SECURITY.md](SECURITY.md) - Security reporting policy
* [docs/VERIFICATION.md](docs/VERIFICATION.md) - Contract verification guide
* [docs/DISCLAIMER.md](docs/DISCLAIMER.md) - General risk and affiliation disclaimer

## Core Design

W3PI is designed as an ownerless protocol.

The deployed core contract is intended to have:

```text
No admin mint
No blacklist
No pause function
No owner-controlled fee changes
No post-deployment parameter control
No upgrade proxy
```

The protocol includes:

```text
BEP-20 token logic
Direct burn accounting
Passive reward entitlement logic
Referral proposal and acceptance logic
Airdrop gift burn reserve logic
AMM trading burn logic for registered pairs
Read-only viewer support through W3PIViewer
```

## Supply

```text
Token name: W3PI
Token symbol: W3PI
Decimals: 18
Maximum total supply: 314,159,265 W3PI
```

Initial supply distribution:

```text
900,000 W3PI to the initial holder
100,000 W3PI to the contract airdrop gift reserve
```

## AMM Trading Burn

Recognized AMM buy/sell transfers through registered pairs apply a fixed trading burn.

The AMM trading burn:

```text
Does not go to an owner
Does not go to a team wallet
Does not go to marketing
Does not go to treasury
Does not increase user reward entitlement
Does not increase referral entitlement
```

It is a permanent token burn mechanism.

## Official Website

```text
https://w3pi.social
```

Always verify contract addresses from the official website, this repository, and BscScan before interacting with the protocol.

## Disclaimer

W3PI does not guarantee profit, token price appreciation, liquidity, exchange listings, trading volume, market value, or user rewards in fiat value.

All smart contract interactions involve risk. Users should review the source code, understand the protocol mechanics, and use their own judgment before interacting with any contract.

## License

This project is released under the MIT License.
