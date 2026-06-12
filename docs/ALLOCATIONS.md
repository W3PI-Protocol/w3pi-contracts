# W3PI Allocations

This document records the initial W3PI reserve allocation after mainnet deployment, AMM pair creation, AMM trading burn verification, and LP token burn.

W3PI is an ownerless Web3 + Pi themed BEP-20 protocol on BNB Smart Chain. The Pi reference is mathematical and symbolic. W3PI is not affiliated with Pi Network, Pi Coin, or any other Pi-branded blockchain, company, foundation, or project.

## Official Token Contract

* Network: BNB Smart Chain Mainnet
* W3PI Core Contract: `0x2ba78a103318bd4e3db45186113527651bb8dcca`
* W3PIViewer Contract: `0xb1fEA36eAcCcF976e990f9d01f3768c9b9EC0e0B`

## Reserve Wallet Allocation

After deployment, the deployer-held W3PI reserve was separated into transparent project-purpose reserve wallets.

These wallets are project-controlled operational reserve wallets. They are not user custody wallets and they do not represent circulating market distribution.

| Purpose                               | Wallet                                       |                            Amount | Transaction                                                          |
| ------------------------------------- | -------------------------------------------- | --------------------------------: | -------------------------------------------------------------------- |
| Bounty Reserve Wallet                 | `0x81Ac24b618bb64791B9f58D75149a92c86DcB5eD` |                    `100,000 W3PI` | `0xe21926d04a96b8882a9da5671b3fc3fecb40df5461bd863a1a9c61996be7ae1e` |
| Community Builder Burn Support Wallet | `0x8bf5974fc49d0B335bbbBC753e21549E548c715b` |                    `100,000 W3PI` | `0xf134d8ad1147a0ae838d9de2b310b839455930bd37c4788cd9c3661822c5e6ff` |
| Team / Operations Reserve Wallet      | `0x34FEf9117F1d28a39cbcC92cc67376573e73a2A1` |                    `100,000 W3PI` | `0xf2e9e2dfb46b922ea9d1a1359fdb51791afd654387621902bfe4eed3921eee0c` |
| Protocol Reserve Wallet               | `0x21D3CA618c36a049133Ac60968E64dC714B6F6E0` | `598,296.573839833333677184 W3PI` | `0x1e6bf69a3ca467527c5ce3c9430480bd797b99ccfc69be29586041008dd50438` |

## Purpose of Allocation

The purpose of this allocation is to separate project reserves by function and reduce deployer-wallet concentration.

The deployer wallet is no longer intended to act as the main W3PI reserve wallet.

## Wallet Purpose Notes

### Bounty Reserve Wallet

Used for community tasks, bounty campaigns, testing rewards, contributor rewards, and ecosystem participation programs.

### Community Builder Burn Support Wallet

Used for Community Builder related burn support, activation support, and community growth support programs.

### Team / Operations Reserve Wallet

Used for operational costs, technical maintenance, infrastructure, website, bot, security review, listing, audit, and administrative project expenses.

### Protocol Reserve Wallet

Used as the main protocol reserve wallet for future ecosystem needs, community programs, security/reputation workstreams, liquidity expansion decisions, audits, integrations, and long-term protocol support.

## Transparency Note

Reserve wallets are project-controlled wallets. They are disclosed for transparency and traceability.

The reserve allocation does not create a guarantee of price, liquidity, listing, reward, or profit. All on-chain actions should be independently verified by users through BNB Smart Chain explorers.
