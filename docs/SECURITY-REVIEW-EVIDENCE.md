# W3PI Security Review Evidence

This document provides public evidence for wallet security systems, block explorers, token lists, listing platforms, and third-party security review teams.

W3PI is an ownerless Web3 + Pi themed BEP-20 protocol deployed on BNB Smart Chain Mainnet.

The protocol uses the mathematical Pi theme symbolically. W3PI is not affiliated with Pi Network, Pi Coin, or any other Pi-branded blockchain, company, foundation, or project.

## Project Identity

```text
Project name: W3PI
Token name: W3PI
Token symbol: W3PI
Official website: https://w3pi.social
Official GitHub: https://github.com/W3PI-Protocol/w3pi-contracts
Network: BNB Smart Chain Mainnet
Chain ID: 56
Token standard: BEP-20 / ERC-20 compatible
Decimals: 18
Maximum total supply: 314,159,265 W3PI
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

W3PI Core Source Code:
https://bscscan.com/address/0x2ba78a103318bd4e3db45186113527651bb8dcca#code

W3PI Token BscScan:
https://bscscan.com/token/0x2ba78a103318bd4e3db45186113527651bb8dcca

W3PIViewer BscScan:
https://bscscan.com/address/0xb1fEA36eAcCcF976e990f9d01f3768c9b9EC0e0B

W3PIViewer Source Code:
https://bscscan.com/address/0xb1fEA36eAcCcF976e990f9d01f3768c9b9EC0e0B#code
```

## Public Repository Evidence

```text
GitHub repository:
https://github.com/W3PI-Protocol/w3pi-contracts

Official contract registry:
https://github.com/W3PI-Protocol/w3pi-contracts/blob/main/CONTRACTS.md

Deployment notes:
https://github.com/W3PI-Protocol/w3pi-contracts/blob/main/DEPLOYMENT.md

Transparency record:
https://github.com/W3PI-Protocol/w3pi-contracts/blob/main/docs/TRANSPARENCY.md

Allocation record:
https://github.com/W3PI-Protocol/w3pi-contracts/blob/main/docs/ALLOCATIONS.md

Verification guide:
https://github.com/W3PI-Protocol/w3pi-contracts/blob/main/docs/VERIFICATION.md

Project metadata:
https://github.com/W3PI-Protocol/w3pi-contracts/blob/main/docs/METADATA.md

Brand assets:
https://github.com/W3PI-Protocol/w3pi-contracts/blob/main/docs/BRAND-ASSETS.md

Disclaimer:
https://github.com/W3PI-Protocol/w3pi-contracts/blob/main/docs/DISCLAIMER.md

GoPlus token security scan snapshot:
https://github.com/W3PI-Protocol/w3pi-contracts/blob/main/docs/scans/goplus-token-security-w3pi-snapshot.pdf
```

## Brand and Wallet Metadata

```text
Primary logo:
https://raw.githubusercontent.com/W3PI-Protocol/w3pi-contracts/main/assets/logo.png

SVG logo:
https://raw.githubusercontent.com/W3PI-Protocol/w3pi-contracts/main/assets/logo.svg

32x32 logo:
https://raw.githubusercontent.com/W3PI-Protocol/w3pi-contracts/main/assets/logo-32.png

256x256 logo:
https://raw.githubusercontent.com/W3PI-Protocol/w3pi-contracts/main/assets/logo-256.png

512x512 logo:
https://raw.githubusercontent.com/W3PI-Protocol/w3pi-contracts/main/assets/logo-512.png
```

Trust Wallet preparation files are available in this repository for review and submission preparation.

```text
Trust Wallet prepared asset:
https://raw.githubusercontent.com/W3PI-Protocol/w3pi-contracts/main/trustwallet/blockchains/smartchain/assets/0x2bA78a103318bd4E3db45186113527651bB8DcCA/logo.png

Trust Wallet prepared info.json:
https://raw.githubusercontent.com/W3PI-Protocol/w3pi-contracts/main/trustwallet/blockchains/smartchain/assets/0x2bA78a103318bd4E3db45186113527651bB8DcCA/info.json
```

These prepared Trust Wallet files do not imply official Trust Wallet listing or approval unless accepted through the relevant Trust Wallet review process.

## Contract Design Summary

The W3PI Core contract is designed as an ownerless protocol.

The deployed core contract is designed with:

```text
No admin mint
No blacklist
No whitelist
No transfer pause
No transfer cooldown
No owner-controlled fee changes
No owner-controlled tax changes
No privileged balance modification
No post-deployment parameter control
No upgrade proxy
No ownership regain mechanism
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

It is a permanent token burn mechanism applied to recognized AMM buy/sell transfers.

## W3PI/WBNB Bootstrap Pair

A small W3PI/WBNB bootstrap pair was created on PancakeSwap V2 for technical verification of AMM behavior.

```text
W3PI/WBNB Pair:
0x796843129ac6Ea42FCCD27Fe9dDc3306bf92aab4

Quote Token:
WBNB

WBNB Address:
0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c
```

Initial bootstrap liquidity:

```text
1,000 W3PI
0.001666666666666666 BNB
```

## AMM Pair and Burn Verification Transactions

```text
Add Liquidity:
0x86c456e71bd6ced1d214cfe8d3765f841ad5579547c0f2c49652ff4942499afb

Pancake Router Approval:
0x29509178947c90784e3e0490ef5c84e2aff66cf510cd6a908e1ae7b0725678c3

createAndRegisterPair(WBNB):
0x9173009fc255ebac9d33ff53821681f3366bcbe354f2ee30dcf96b46a2afffa3

Buy Test 1:
0x4e184a4f9970672d4f364a5693778158210d7e55a7cdd96c79cd7fa49217a97f

Buy Test 2:
0x0135bfd7900a636e5f66a0becb80772af372b6c4d9fe00f240b2dbef58f3f5b3

Sell Test:
0x4c2735fa878cf92cdfeb409844ed1e744c39ded9641aecba256c595c8f731ac7

External Market Buy Observed:
0x9f58fe2d7c537ea8494ac57052fa3aa920dec74d387e2458dd3ceba6054d34cf

Additional External Market Buy Observed:
0x87e8067911c485339266af3f5ee841d1d8583dc5bf75558e61439b049649f786
```

The buy and sell test transactions verified that the fixed AMM trading burn works on recognized AMM transfers.

External market buys were also observed after the initial AMM burn verification, and the AMM burn behavior remained consistent.

Full details are published in:

```text
https://github.com/W3PI-Protocol/w3pi-contracts/blob/main/docs/TRANSPARENCY.md
```

## LP Token Burn

After AMM trading burn verification, the initial bootstrap LP tokens were sent to the burn address.

```text
LP Token Burn / Dead Transfer:
0x8820a05d60af9885359aac24b95ca481c597bed98cb4cad05cfdf47aa1842855

Burn address:
0x000000000000000000000000000000000000dEaD

LP token / Pair contract:
0x796843129ac6Ea42FCCD27Fe9dDc3306bf92aab4

Amount sent to burn address:
1.29099444873580437 Cake-LP
```

The initial bootstrap LP tokens were not removed by the deployer. They were sent to the burn address after technical verification.

## Reserve Wallet Allocation

After the bootstrap liquidity test and AMM burn verification, the deployer-held W3PI reserve was separated into transparent project-purpose reserve wallets.

```text
Bounty Reserve Wallet:
0x81Ac24b618bb64791B9f58D75149a92c86DcB5eD
Amount: 100,000 W3PI
Transaction: 0xe21926d04a96b8882a9da5671b3fc3fecb40df5461bd863a1a9c61996be7ae1e

Community Builder Burn Support Wallet:
0x8bf5974fc49d0B335bbbBC753e21549E548c715b
Amount: 100,000 W3PI
Transaction: 0xf134d8ad1147a0ae838d9de2b310b839455930bd37c4788cd9c3661822c5e6ff

Team / Operations Reserve Wallet:
0x34FEf9117F1d28a39cbcC92cc67376573e73a2A1
Amount: 100,000 W3PI
Transaction: 0xf2e9e2dfb46b922ea9d1a1359fdb51791afd654387621902bfe4eed3921eee0c

Protocol Reserve Wallet:
0x21D3CA618c36a049133Ac60968E64dC714B6F6E0
Amount: 598,296.573839833333677184 W3PI
Transaction: 0x1e6bf69a3ca467527c5ce3c9430480bd797b99ccfc69be29586041008dd50438
```

These wallets are project-controlled operational reserve wallets. They are not user custody wallets and they do not represent circulating market distribution.

The purpose of this allocation is to separate project reserves by function and reduce deployer-wallet concentration.

Full details are published in:

```text
https://github.com/W3PI-Protocol/w3pi-contracts/blob/main/docs/ALLOCATIONS.md
```

## Automated Token Security Scan Snapshot

A GoPlus automated token security scan snapshot was saved as supporting evidence for the W3PI Core contract.

```text
GoPlus scan page:
https://console.gopluslabs.io/token-security/56/0x2ba78a103318bd4e3db45186113527651bb8dcca

Snapshot file:
https://github.com/W3PI-Protocol/w3pi-contracts/blob/main/docs/scans/goplus-token-security-w3pi-snapshot.pdf
```

The snapshot reported:

```text
Risky item: 0
Attention item: 0
Contract source code verified
No proxy
No mint function
No ownership retrieval function found
Owner cannot change balances
No hidden owner
No self-destruct function found
No external call risk found
No gas abuse activity found
Not a honeypot
No code found to suspend trading
Holders can sell all tokens
The token can be bought
No trading cooldown function
No anti-whale transaction limit
Tax cannot be modified
No blacklist
No whitelist
No personal address tax changes found
Owner holdings: 0 W3PI / 0.00%
Creator holdings: 100 W3PI / 0.01%
LP locked/burned: 100%
```

This is an automated token security scan snapshot, not a manual audit. It is provided as supporting scanner evidence only.

The GoPlus scanner displayed `Buy Tax: 3.00%`, `Sell Tax: 1.32%`, and `Transfer Tax: 0.00%`. The sell tax value appears to be an automated simulation estimate and does not match the observed on-chain AMM burn behavior. W3PI's registered AMM pair transfers apply a fixed `3%` token burn on recognized AMM buy-side and sell-side transfers, while normal wallet-to-wallet transfers have `0%` transfer tax. The verified AMM burn transactions in the Transparency Record should be used as the source of truth for W3PI's AMM burn behavior.

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

## Security Scanner Context

Some third-party scanners may temporarily show outdated or cached warnings for newly deployed or newly verified contracts.

If a scanner shows an outdated warning such as:

```text
Unverified Contract Source Code
```

the W3PI team requests a manual refresh or false-positive review, because the W3PI Core contract is source-code verified on BscScan.

Verified source code:

```text
https://bscscan.com/address/0x2ba78a103318bd4e3db45186113527651bb8dcca#code
```

If a scanner shows an ownership warning based only on a missing standard `renounceOwnership()` pattern, the W3PI team requests a manual review of the actual privileged capabilities. The deployed W3PI Core contract is designed without admin mint, blacklist, pause, owner-controlled tax changes, privileged balance modification, upgrade proxy, or ownership regain mechanism.

Current scanner follow-up context:

```text
HashDit / RedAlarm:
A manual refresh / false-positive follow-up was submitted because the scanner still displayed an outdated Unverified Contract Source Code warning even though the W3PI Core contract is verified on BscScan. The follow-up also referenced Blockaid ticket 1281934.

PancakeSwap:
The PancakeSwap warning is expected to be related to HashDit / RedAlarm third-party scanner data and may change after HashDit refreshes its result.

DappBay / GoPlus:
If an Ownership Not Renounced alert appears, W3PI requests review based on actual privileged capabilities, because the contract has no admin mint, blacklist, owner-controlled tax modification, privileged balance modification, transfer pause, upgrade proxy, or ownership regain mechanism.
```

## Blockaid False-Positive Review Result

Blockaid Security Team completed a manual review for the W3PI Core contract and confirmed that the previous flagging was incorrect.

```text
Blockaid ticket ID:
1281934

Reviewed contract:
0x2ba78a103318bd4e3db45186113527651bb8dcca

Review result:
Flagging was incorrect and has been modified accordingly.

Propagation note:
Blockaid noted that the fix may take up to 24 hours to fully propagate across all systems.
```

After this correction, MetaMask warnings observed on w3pi.social interactions were reduced from stronger malicious/risky warnings to a softer address verification warning:

```text
We can't verify this address. It may be new or unverified. Only continue if you trust the source.
```

Trust Wallet and other wallet or scanner interfaces may still show cached or third-party scanner warnings until their own data sources refresh. W3PI does not ask users to bypass wallet warnings and continues to use official review channels for false-positive correction requests.

## False Positive Review Note

If W3PI, w3pi.social, or the official contract addresses are classified as suspicious, phishing, wallet-draining, or malicious by a wallet security system or third-party scanner, the W3PI team requests a manual false-positive review.

Relevant evidence:

```text
Verified source code on BscScan
Public GitHub repository
Official domain
Public contract registry
Transparent deployment notes
Public transparency record
Public allocation record
AMM pair registration transaction
AMM trading burn verification transactions
LP token burn transaction
Reduced deployer-wallet concentration
No admin mint
No blacklist
No whitelist
No transfer pause
No transfer cooldown
No owner-controlled fee changes
No privileged balance modification
No upgrade proxy
Public logo and token metadata assets
Blockaid false-positive correction, ticket 1281934
GoPlus automated token security scan snapshot showing Risky item 0 and Attention item 0
```

## Important Safety Notice

W3PI does not ask users to disable wallet security warnings.

If a wallet security warning appears, users should not ignore it blindly. The project team should submit official review or false-positive correction requests through the relevant wallet or security vendor channels.

## Disclaimer

W3PI is an experimental Web3 protocol token.

W3PI does not guarantee profit, token price appreciation, liquidity, exchange listings, trading volume, market value, user rewards in fiat value, or third-party platform approval.

W3PI is not affiliated with Pi Network, Pi Coin, or any other Pi-branded blockchain, company, foundation, or project.

All smart contract interactions involve risk. Users should review the source code, understand the protocol mechanics, verify official links, and use their own judgment before interacting with any contract.
