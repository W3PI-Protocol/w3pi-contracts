## AMM Trading Burn Verification

W3PI includes a fixed 3% AMM trading burn for recognized AMM buy/sell transfers.

The AMM trading burn does not create user reward entitlement, referral entitlement, or team allocation. It is a permanent token burn applied to recognized AMM buy/sell transfers.

### Buy Test 1

| Action     | Transaction                                                          |
| ---------- | -------------------------------------------------------------------- |
| Buy Test 1 | `0x4e184a4f9970672d4f364a5693778158210d7e55a7cdd96c79cd7fa49217a97f` |

Observed behavior:

* Approximately `10 W3PI` transferred out from the pair
* Approximately `0.3 W3PI` burned
* Approximately `9.7 W3PI` received by the buyer
* AMM burn rate verified: approximately `3%`

### Buy Test 2

| Action     | Transaction                    |
| ---------- | ------------------------------ |
| Buy Test 2 | `0x0135bfd7900a636e5f66a0becb80772af372b6c4d9fe00f240b2dbef58f3f5b3` |

Observed behavior:

* Approximately 10 W3PI transferred out from the pair
* Approximately 0.300000000000010516 W3PI burned
* Approximately 9.700000000000340018 W3PI received by the buyer
* AMM burn rate verified: approximately `3%`

### Sell Test

| Action    | Transaction                                                          |
| --------- | -------------------------------------------------------------------- |
| Sell Test | `0x4c2735fa878cf92cdfeb409844ed1e744c39ded9641aecba256c595c8f731ac7` |

Observed behavior:

* Approximately `20 W3PI` transferred by the seller
* Approximately `0.6 W3PI` burned
* Approximately `19.4 W3PI` received by the pair
* AMM burn rate verified: approximately `3%`

## Automated Token Security Scan Snapshot

A GoPlus automated token security scan snapshot was saved as supporting transparency evidence for the W3PI Core contract.

File:

[docs/scans/goplus-token-security-w3pi-snapshot.pdf](./scans/goplus-token-security-w3pi-snapshot.pdf)

GoPlus scan page:

```text
https://console.gopluslabs.io/token-security/56/0x2ba78a103318bd4e3db45186113527651bb8dcca
```

Snapshot highlights:

```text
Risky item: 0
Attention item: 0
Contract source code verified
No proxy
No mint function
No hidden owner
No external call risk found
Not a honeypot
No blacklist
No whitelist
Tax cannot be modified
Owner holdings: 0
Creator holdings: 100 W3PI / 0.01%
LP locked/burned: 100%
```

Important note:

This is an automated token security scan snapshot, not a manual audit. Scanner output may include automated simulation estimates. Verified on-chain behavior should be referenced from the documented AMM buy/sell transactions in this transparency record.


