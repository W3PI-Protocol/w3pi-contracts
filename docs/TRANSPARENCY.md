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
