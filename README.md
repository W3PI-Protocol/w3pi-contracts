# W3PI Contracts

W3PI is an ownerless Web3 + Pi themed BEP-20 protocol designed for BNB Smart Chain.

The protocol uses the mathematical Pi theme symbolically. W3PI is not affiliated with Pi Network, Pi Coin, or any other Pi-branded blockchain, company, foundation, or project.

## Repository Documents

```text
Contracts:
contracts/W3PI_Core.sol
contracts/W3PIViewer.sol

Security policy:
SECURITY.md

Deployment notes:
DEPLOYMENT.md

Official contract registry:
CONTRACTS.md
```

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

## Deployment

Official deployed contract addresses will be published after BNB Smart Chain mainnet deployment and source verification.

Always verify contract addresses from the official website, this repository, and BscScan before interacting with the protocol.

Official website:

```text
https://w3pi.social
```

## Disclaimer

W3PI does not guarantee profit, token price appreciation, liquidity, exchange listings, or market value.

All smart contract interactions involve risk. Users should review the source code, understand the protocol mechanics, and use their own judgment before interacting with any contract.

## License

This project is released under the MIT License.
