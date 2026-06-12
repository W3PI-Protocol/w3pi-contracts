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
Token page: https://bscscan.com/token/0x2ba78a103318bd4e3db45186113527651bb8dcca
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

README.md
SECURITY.md
DEPLOYMENT.md
CONTRACTS.md

docs/ALLOCATIONS.md
docs/TRANSPARENCY.md
docs/SECURITY-REVIEW-EVIDENCE.md
docs/METADATA.md
docs/BRAND-ASSETS.md
docs/VERIFICATION.md
docs/DISCLAIMER.md

assets/
```

## Repository Documents

* [CONTRACTS.md](CONTRACTS.md) - Official W3PI contract address registry
* [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment configuration and quote token whitelist
* [SECURITY.md](SECURITY.md) - Security reporting policy
* [docs/ALLOCATIONS.md](docs/ALLOCATIONS.md) - Initial project reserve allocation record
* [docs/TRANSPARENCY.md](docs/TRANSPARENCY.md) - Pair, AMM burn test, LP burn, and allocation transparency record
* [docs/SECURITY-REVIEW-EVIDENCE.md](docs/SECURITY-REVIEW-EVIDENCE.md) - Evidence package for security scanners, wallet providers, and listing reviews
* [docs/METADATA.md](docs/METADATA.md) - Project metadata and official links
* [docs/BRAND-ASSETS.md](docs/BRAND-ASSETS.md) - Logo and brand asset references
* [docs/VERIFICATION.md](docs/VERIFICATION.md) - Contract verification guide
* [docs/DISCLAIMER.md](docs/DISCLAIMER.md) - General risk and affiliation disclaimer

## Core Design

W3PI is designed as an ownerless protocol.

The deployed core contract is intended to have:

```text
No admin mint
No blacklist
No whitelist
No pause function
No transfer cooldown
No owner-controlled fee changes
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

After deployment, the deployer-held W3PI reserve was separated into transparent project-purpose reserve wallets.

Allocation details are published here:

```text
docs/ALLOCATIONS.md
docs/TRANSPARENCY.md
```

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

Bootstrap liquidity:

```text
1,000 W3PI
0.001666666666666666 BNB
```

Pair and AMM verification records are published in:

```text
docs/TRANSPARENCY.md
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

The initial W3PI/WBNB pair was registered in the W3PI Core contract, buy/sell AMM burn behavior was tested, and the initial LP tokens were sent to the burn address.

```text
Burn address:
0x000000000000000000000000000000000000dEaD
```

Full transaction records are available in:

```text
docs/TRANSPARENCY.md
```

## Reserve Wallet Transparency

The initial deployer-held reserve was separated into purpose-based project reserve wallets:

```text
Bounty Reserve Wallet
Community Builder Burn Support Wallet
Team / Operations Reserve Wallet
Protocol Reserve Wallet
```

These wallets are project-controlled operational reserve wallets. They are not user custody wallets and they do not represent circulating market distribution.

Full wallet addresses, transferred amounts, and transaction hashes are available in:

```text
docs/ALLOCATIONS.md
```

## Security and Review Evidence

W3PI maintains public evidence records for security scanners, wallet providers, block explorers, and listing reviews.

Relevant documents:

```text
docs/SECURITY-REVIEW-EVIDENCE.md
docs/TRANSPARENCY.md
docs/ALLOCATIONS.md
docs/VERIFICATION.md
docs/METADATA.md
```

The deployed W3PI Core contract is source-code verified on BscScan.

Some third-party scanners may temporarily show outdated or cached warnings for newly deployed or newly verified contracts. Public verification and transparency records are maintained in this repository for independent review.

## Official Links

```text
Website: https://w3pi.social
GitHub: https://github.com/W3PI-Protocol/w3pi-contracts
X: https://x.com/W3PIOfficial
Telegram Bot / Mini App: https://t.me/W3PIBot
Official Telegram Channel: https://t.me/W3PIOfficial
Global Chat Group: https://t.me/W3PI_Chat
```

Always verify contract addresses from the official website, this repository, and BscScan before interacting with the protocol.

## Disclaimer

W3PI is an experimental Web3 protocol token.

W3PI does not guarantee profit, token price appreciation, liquidity, exchange listings, trading volume, market value, user rewards in fiat value, or third-party platform approval.

All smart contract interactions involve risk. Users should review the source code, understand the protocol mechanics, verify official links, and use their own judgment before interacting with any contract.

## License

This project is released under the MIT License.
