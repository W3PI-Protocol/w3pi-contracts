# W3PI Security Review Evidence

This document provides public evidence for wallet security systems, block explorers, token lists, and third-party security review teams.

## Project Identity

```text
Project name: W3PI
Official website: https://w3pi.social
Official GitHub: https://github.com/W3PI-Protocol/w3pi-contracts
Network: BNB Smart Chain Mainnet
Chain ID: 56
Token standard: BEP-20
```

## Official Contracts

```text
W3PI Core Contract:
0x2ba78a103318bd4e3db45186113527651bb8dcca

W3PIViewer Contract:
0xb1fEA36eAcCcF976e990f9d01f3768c9b9EC0e0B
```

## Verified Source Code

```text
W3PI Core BscScan:
https://bscscan.com/address/0x2ba78a103318bd4e3db45186113527651bb8dcca

W3PIViewer BscScan:
https://bscscan.com/address/0xb1fEA36eAcCcF976e990f9d01f3768c9b9EC0e0B
```

## Contract Design Summary

The W3PI core contract is designed as an ownerless protocol.

The deployed core contract is intended to have:

```text
No admin mint
No blacklist
No pause function
No owner-controlled fee changes
No post-deployment parameter control
No upgrade proxy
```

## AMM Trading Burn

Recognized AMM buy/sell transfers through registered pairs apply a fixed AMM trading burn.

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

## Official Communication Channels

```text
Website:
https://w3pi.social

GitHub:
https://github.com/W3PI-Protocol/w3pi-contracts

Telegram Bot / Mini App:
https://t.me/W3PIBot

Official Telegram Channel:
https://t.me/W3PIOfficial

Global Chat:
https://t.me/W3PI_Chat

X / Twitter:
https://x.com/W3PIOfficial
```

## False Positive Review Note

If W3PI, w3pi.social, or the official contract addresses are classified as suspicious, phishing, wallet-draining, or malicious by a wallet security system or third-party scanner, the W3PI team requests a manual false-positive review.

Relevant evidence:

```text
Verified source code on BscScan
Public GitHub repository
Official domain
Public contract registry
Transparent deployment notes
No admin mint
No blacklist
No pause function
No owner-controlled fee changes
No upgrade proxy
```

## Disclaimer

W3PI does not guarantee profit, token price appreciation, liquidity, exchange listings, trading volume, market value, or user rewards in fiat value.

W3PI is not affiliated with Pi Network, Pi Coin, or any other Pi-branded blockchain, company, foundation, or project.
