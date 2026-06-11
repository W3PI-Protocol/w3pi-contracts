// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title W3PI
 * @notice W3PI means Web3 + Pi. The Pi reference is mathematical and symbolic only.
 * @notice W3PI is NOT affiliated with Pi Network, Pi Coin, any Pi-branded blockchain,
 *         or any other external project, company, foundation, or ecosystem.
 * @notice This contract is intentionally ownerless. getOwner() returns address(0), and there is
 *         no admin mint, blacklist, pause, fee control, or post-deployment parameter control.
 * @notice This contract does NOT guarantee profit, yield, APR, APY, price appreciation,
 *         liquidity, market value, or any USD/fiat-denominated return.
 *
 * @notice Pi-aligned scarcity story:
 *         - The hard maximum supply is 314,159,265 W3PI, symbolically derived from
 *           pi ~= 3.14159265 x 100,000,000.
 *         - This value is a hard safety cap, not a target supply and not a promise that
 *           all tokens will ever enter circulation.
 *         - The 314,159,265 W3PI maximum supply is a hard upper bound, not an expected
 *           final supply. The protocol caps minting; it does not force maximum supply
 *           issuance.
 *         - Depending on user behavior, especially aggressive claim-and-reburn strategies,
 *           the realized totalSupply may remain significantly below the hard cap because
 *           claimed tokens can be repeatedly burned to open new entitlement.
 *         - In aggressive recursive testing, the effective burn cap was able to close while
 *           totalSupply remained far below the 314,159,265 W3PI maximum supply. This is an
 *           expected result of repeated re-burning, not a supply-accounting error.
 *         - The maximum total effective burn cap is set below 100M at 99,415,639 W3PI.
 *           This tighter burn cap is designed so the conservative long-term accounting model
 *           remains under the Pi-aligned hard cap when direct net claims, referral accounting,
 *           recursive re-burn behavior, rounding buffers, and edge cases are considered.
 * @notice Core accounting model:
 *         - Rewards are accounted only in token units.
 *         - Each user's gross entitlement is capped at 3x of the user's effective burned amount.
 *         - The amount entered in normal user burn functions is recorded directly as
 *           effective burn. To protect users from accidentally burning their entire balance,
 *           one burn transaction can burn at most 99% of the caller's current W3PI balance.
 *         - Claims mint only 90% net because 10% of each gross claim is treated as virtual burn.
 *         - A fully used 3x gross entitlement therefore produces about 2.7x net minted tokens,
 *           not a guaranteed net 3x.
 *         - Referral rewards are NOT unlimited extra yield. They only accelerate reaching the
 *           same user-level 3x gross entitlement cap.
 *         - The reward schedule is account-level, not position-level. The first burn starts
 *           the user's single reward timeline. Later burns join the same timeline and do not
 *           create separate independent reward positions with a new Year-1 schedule.
 *         - If the user's currently queued passive/referral buckets already cover the remaining
 *           entitlement, additional elapsed time is not saved for retroactive reward creation
 *           after a later burn. Later burns open new entitlement from that point forward; they
 *           do not revive skipped time as retroactive passive rewards.
 *         - The protocol uses a conservative mint-cap policy. If remaining mint capacity is zero
 *           before a normal burn or gift burn, new entitlement cannot be opened even if the burn
 *           itself could reduce current totalSupply and create future supply room.
 *
 *
 * @notice Referral distribution ceiling:
 *         - Referral rewards are not unlimited emissions and are not measured against the
 *           full MAX_TOTAL_SUPPLY as if the whole supply could become referral distribution.
 *         - Referral reward generation is bounded by the global effective burn cap and the
 *           maximum referral distribution percent.
 *         - MAX_TOTAL_EFFECTIVE_BURN is fixed at 99,415,639 W3PI.
 *         - MAX_TOTAL_REFERRAL_PERCENT is fixed at 50%.
 *         - Therefore, the theoretical maximum referral reward base generated from effective
 *           burns is 49,707,819.5 W3PI before user-level entitlement, mint-cap, timing,
 *           final-season, and practical participation limits are applied.
 *         - This theoretical referral ceiling is approximately one sixth of the 314,159,265
 *           W3PI hard maximum supply. It is a bounded community-growth accounting area,
 *           not an unlimited yield source.
 *         - Referral rewards remain accounting entries inside user-level 3x gross entitlement
 *           limits and cannot bypass the hard supply cap, mint cap, effective burn cap,
 *           or user entitlement cap.
 *
 * @notice Trading-burn model:
 *         - Recognized AMM buy/sell transfers apply a fixed 3% W3PI trading burn during
 *           the normal phase, including the full period while users can still burn W3PI
 *           and open 3x gross entitlement.
 *         - The trading burn is not sent to owner, team, marketing, treasury, or liquidity wallets.
 *           It is permanently burned and removed from totalSupply.
 *         - Because every recognized AMM trade normally removes 3% of the transferred W3PI
 *           from supply, the mechanism can reduce long-term token-supply pressure and may
 *           support liquidity-depth dynamics as trading volume grows. This is a supply-mechanics
 *           design, not a promise of price appreciation, USD value, liquidity, exchange listing,
 *           or fiat profit.
 *         - After final season has started, AMM trading burn remains active only while
 *           totalSupply is above the Pi-aligned terminal floor of 3,141,592.65 W3PI.
 *           If a final-season AMM burn would reduce totalSupply below this floor, only the
 *           amount above the floor is burned. Once totalSupply is at or below the floor,
 *           the AMM trading burn fee becomes zero.
 *         - This final-season floor does not disable AMM trading burn before final season.
 *           Before final season, the 3% AMM trading burn continues even if market activity
 *           reduces supply, because normal burn/entitlement mechanics are still active.
 *         - Trading burn does not increase burnedAmount, does not create maxEntitlement,
 *           does not create passive rewards, does not create referral rewards, and does not
 *           count toward totalEffectiveBurned.
 *         - Trading burn is only applied when sender or recipient is a registered AMM pair.
 *           Normal wallet-to-wallet transfers, user burn functions, gift burns, claims,
 *           referral proposal/acceptance, minting, airdrop activation, and final-season
 *           settlement are not treated as trading-burn events.
 *         - Pair registration is ownerless and permissionless, but only pairs against
 *           pre-approved quote tokens can be registered. A fake ABC token pair cannot become
 *           a recognized trading pair unless ABC was included in the immutable deployment whitelist.

 * @notice Claim and missed-reward policy:
 *         - On each normal claim, passive and referral buckets are settled once.
 *         - Any unpaid portion caused by the user's 3x entitlement cap or the global supply/mint
 *           cap is recorded as missed and is not carried forward as guaranteed protocol debt.
 *         - Normal-phase missed amounts are recorded for reporting and UI incentive purposes.
 *           During the normal phase, only actually payableGross consumes claimedTotal. Missed
 *           amounts are not automatically treated as settled entitlement because the account may
 *           continue burning, receiving referral accounting, and accruing rewards before final season.
 *         - Final season is different: it is a closing settlement phase. In final season, the
 *           whole unlocked finalSeasonGross is settled; the payable part is minted and the unpaid
 *           part is recorded as missed, but both consume gross entitlement capacity.
 *         - totalRemainingGrossEntitlement means remaining gross entitlement capacity; it is not
 *           a guaranteed debt and must not be presented as a guaranteed payable liability.
 *
 * @notice Preview/status-code documentation:
 *         - Preview/statusCode values are returned by the external W3PIViewer helper contract.
 *         - The core W3PI contract does not return preview status codes directly.
 *         - This source file keeps a human-readable reference so users can understand
 *           viewer status codes from the verified contract source.
 *         - Keep this reference synchronized with W3PIViewer before deployment.
 *         - Preview results are instant simulations only. They are not reservations
 *           and may change before a transaction is mined.
 *
 * @notice Referral signaling story:
 *         - Referral proposal signaling uses a 2π-symbolic transfer amount of 0.628318 W3PI.
 *         - Referral acceptance returns a π-symbolic amount of 0.314159 W3PI to the proposer.
 *         - After acceptance, the accepting wallet keeps approximately 0.314159 W3PI as a
 *           symbolic Pi remainder from the proposal signal.
 *         - These amounts are symbolic network-signaling values, not fees promising profit.
 *         - Referral proposal transfers are non-refundable. If the target does not accept,
 *           the offer expires, or the target joins through another valid referral path,
 *           the sent proposal amount remains with the target and is not automatically returned.
 *
 * @notice Gift burns and airdrop activation burns:
 *         - Permissionless gift burns are sponsorship/support burns. They spend only the payer's
 *           own tokens and credit burn power/entitlement to an already registered and active
 *           beneficiary with an assigned upline.
 *         - Gift burns cannot burn the beneficiary's balance, cannot assign or change the
 *           beneficiary's referral, and route referral accounting through the beneficiary's
 *           existing upline chain.
 *         - Gift burns may increase the beneficiary's burnedAmount, maxEntitlement, referral career
 *           level, active referral qualification, and may create referral rewards for the
 *           beneficiary's existing upline chain.
 *         - Airdrop gift burns are reserve-funded activation burns. They are NOT ordinary 99%
 *           effective user burns. The actual reserve amount burned is credited as the same amount
 *           of burn power to the beneficiary, subject to reserve availability and the global
 *           effective burn cap.
 *         - Gift burns and airdrop activation burns consume the same global effective burn capacity
 *           as ordinary burns.
 *         - When final season starts, any unused airdrop gift reserve is burned only as
 *           supply cleanup. This cleanup burn creates no user entitlement, no referral
 *           rewards, and no increase to totalEffectiveBurned. It only reduces totalSupply.
 *
 * @notice Recursive re-burn behavior:
 *         - Claimed tokens are standard ERC20 tokens. They may be transferred and may be burned again.
 *         - If a user re-burns previously claimed tokens, that burn may create new gross entitlement,
 *           but only under the same burn, accrual, 3x gross cap, 10% virtual claim burn,
 *           Pi-aligned effective burn cap, and Pi-aligned hard supply cap rules.
 *         - Recursive re-burn behavior is an intentional long-term economic design risk, not a
 *           shortcut around the time schedule.
 *
 * @notice Timing disclosure for recursive re-burn behavior under the current rate schedule:
 *         - A single account-level burn timeline reaches full 3x gross entitlement in about 21.6 months.
 *         - In an aggressive strategy where users claim and re-burn available net rewards as early
 *           as possible, reaching the effective burn cap and completing final-season distribution
 *           is estimated at about 59 months, roughly 5 years.
 *         - In a slower full-cycle strategy where each account-level reward cycle reaches its full
 *           3x gross entitlement before net claimed tokens are re-burned, the process is estimated at about
 *           128 months, roughly 10.7 years.
 *         - These timing estimates are approximate token-accounting model estimates only. If users
 *           delay claims, do not re-burn, stop interacting, or if network/market behavior differs,
 *           there is no guaranteed maximum completion time.
 *
 * @notice The Pi theme is a narrative and mathematical design anchor for bounded expansion,
 *         circular community growth, and constrained token accounting. It does not imply price
 *         stability, fiat value, investment return, or affiliation with any other Pi-branded project.
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner_, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakePair {
    function token0() external view returns (address);
    function token1() external view returns (address);
}

contract W3PI is Context, IBEP20, ReentrancyGuard {
    string private constant _name = "W3PI";
    string private constant _symbol = "W3PI";
    uint8 private constant _decimals = 18;

    uint256 private constant INITIAL_OWNER_MINT = 900_000 * 10**18;
    uint256 public constant AIRDROP_GIFT_RESERVE = 100_000 * 10**18;
    uint256 public constant AIRDROP_GIFT_BURN_AMOUNT = 10 * 10**18;
    uint256 public constant MAX_AIRDROP_GIFTS_PER_SPONSOR = 5;

    /**
     * @dev Pi-aligned hard supply model.
     *
     * MAX_TOTAL_SUPPLY is 314,159,265 W3PI, symbolically derived from
     * pi ~= 3.14159265 x 100,000,000.
     *
     * This is a conservative hard safety cap, not a target supply and not a promise
     * that all tokens will enter circulation.
     *
     * The maximum effective burn cap is intentionally set below 100M at 99,415,639 W3PI.
     * This keeps the conservative accounting model below the Pi-aligned cap when the
     * following are considered together: 3x gross entitlement, 10% virtual claim burn,
     * referral accounting, recursive re-burn behavior, rounding buffers, airdrop activation
     * burns, and other edge-case execution paths.
     *
     * The Pi narrative is symbolic only. It does not imply price stability, USD value,
     * liquidity, yield, profit, or any affiliation with Pi Network, Pi Coin, or any
     * other Pi-branded project.
     */
    uint256 public constant MAX_TOTAL_SUPPLY = 314_159_265 * 10**18;
    uint256 public constant MAX_TOTAL_MINTED_SUPPLY = 314_159_265 * 10**18;

    uint256 public constant BPS_DENOMINATOR = 10_000;
    // Burn amount is recorded directly as effective burn. This constant is kept as a public
    // compatibility/readability value for frontends and explorers.
    uint256 public constant BURN_EFFECTIVE_BPS = 10_000; // 100% of burn input becomes effective burn
    // A single normal/gift burn may burn at most 99% of the payer's current W3PI balance.
    uint256 public constant MAX_SINGLE_BURN_BALANCE_BPS = 9900;
    uint256 public constant CLAIM_BURN_BPS = 1000;     // 10% virtual burn
    // Fixed 3% trading burn for recognized AMM buy/sell transfers only.
    // This value is intentionally constant and cannot be changed after deployment.
    uint256 public constant TRADING_BURN_FEE_BPS = 300;

    // Final-season AMM trading burn cannot reduce totalSupply below 3,141,592.65 W3PI.
    // This Pi-aligned terminal supply floor activates only after finalSeasonStarted is true.
    // Before final season, AMM trading burn continues normally under the fixed 3% rule.
    uint256 public constant AMM_TRADING_BURN_SUPPLY_FLOOR =
        3_141_592_650000000000000000; // 3,141,592.65 W3PI

    uint256 public constant ENTITLEMENT_MULTIPLIER = 3;

    uint256 public constant MIN_BURN_AMOUNT = 10 * 10**18;
    uint256 public constant MIN_REFERRAL_BURN = 100 * 10**18;
    uint256 public constant MAX_TOTAL_EFFECTIVE_BURN = 99_415_639 * 10**18;

    uint256 public constant MONTHLY_RATE_YEAR_1 = 1500;      // 15%
    uint256 public constant MONTHLY_RATE_YEAR_2 = 1250;      // 12.5%
    uint256 public constant MONTHLY_RATE_YEAR_3 = 1000;      // 10%
    uint256 public constant MONTHLY_RATE_YEAR_4_PLUS = 750;  // 7.5%

    uint256 public constant YEAR_DURATION = 360 days;
    uint256 public constant MONTH_DURATION = 30 days;

    uint256 public constant FINAL_SEASON_TOTAL_PERIODS = 20;
    uint256 public constant FINAL_SEASON_MAX_DURATION = FINAL_SEASON_TOTAL_PERIODS * MONTH_DURATION;

    uint256 public constant REF_PROPOSE_AMOUNT = 628318000000000000; // 0.628318 W3PI, approx. 2 x Pi-symbolic proposal signal
    uint256 public constant REF_ACCEPT_AMOUNT = 314159000000000000;  // 0.314159 W3PI, Pi-symbolic acceptance return
    uint256 public constant REF_EXPIRE_TIME = 1 hours;

    uint256 public constant MAX_REFERRAL_SEARCH_DEPTH = 20;
    uint256 public constant MAX_TOTAL_REFERRAL_PERCENT = 50;

    /**
     * @dev Theoretical maximum referral reward base generated from effective burns.
     *      MAX_TOTAL_EFFECTIVE_BURN is 99,415,639 W3PI and MAX_TOTAL_REFERRAL_PERCENT
     *      is 50%, so the theoretical ceiling is 49,707,819.5 W3PI.
     *
     *      This is not extra mint capacity and not guaranteed distribution. It is a transparent
     *      upper-bound reference before user-level 3x entitlement limits, mint-cap limits,
     *      final-season limits, timing limits, and actual participation behavior are applied.
     */
    uint256 public constant THEORETICAL_MAX_REFERRAL_REWARD_BASE =
        (MAX_TOTAL_EFFECTIVE_BURN * MAX_TOTAL_REFERRAL_PERCENT) / 100;

    uint256 public constant FALLBACK_PERCENT = 1;

    address public immutable CONTRACT_ADDRESS;
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    /**
     * @dev Ownerless AMM recognition model.
     *
     * allowedQuoteTokens is fixed at deployment from quoteTokens_ constructor input.
     * No owner/admin can add or remove quote tokens later.
     *
     * automatedMarketMakerPairs is permissionless to populate, but only by using
     * createAndRegisterPair() with an allowed quote token. This allows anyone to open
     * W3PI/WBNB, W3PI/USDT, W3PI/USDC, W3PI/BTCB, etc. when those quote tokens were
     * included in the deployment whitelist, while rejecting arbitrary ABC pairs.
     *
     * Trading burn is applied only when either sender or recipient is a registered pair.
     * Adding liquidity to a registered pair is also a transfer into the pair, so frontends and
     * liquidity providers should treat W3PI as a fee-on-transfer token for AMM operations.
     */
    address public immutable pancakeRouter;
    address public immutable pancakeFactory;

    mapping(address => bool) public allowedQuoteTokens;
    mapping(address => bool) public automatedMarketMakerPairs;

    uint256 public totalTradingBurned;

    uint256 private _totalSupply;
    uint256 public totalMintedSupply;

    uint256 public totalEffectiveBurned;
    uint256 public totalEntitlementIssued;
    uint256 public totalRemainingGrossEntitlement;

    bool public burnClosed;
    uint256 public burnCloseTimestamp;

    bool public finalSeasonStarted;
    uint256 public finalSeasonStartTimestamp;

    uint256 public totalAirdropGiftBurned;
    uint256 public remainingAirdropGiftReserve;
    uint256 public totalUnusedAirdropGiftReserveBurned;

    mapping(address => bool) public hasReceivedAirdropGift;
    mapping(address => uint256) public sponsorAirdropGiftCount;

    struct User {
        uint256 burnedAmount;
        address upline;

        uint256 refRewards;
        uint256 pendingPassiveGross;
        uint256 maxEntitlement;
        uint256 claimedTotal;
        uint256 missedRewardsDueToCap;

        uint256 rewardStartTimestamp;
        uint256 lastClaimTimestamp;

        uint256 finalSeasonRemainingSnapshot;
        uint256 finalSeasonClaimedFromSnapshot;
        uint256 finalSeasonClaimTimestamp;
        bool finalSeasonSnapshotted;
    }

    struct RefOffer {
        address proposer;
        uint256 timestamp;
    }

    struct NormalClaimContext {
        uint256 passiveGross;
        uint256 referralGross;
        uint256 theoreticalGross;
        uint256 payableGross;
    }

    struct ClaimEventContext {
        bool isFinalSeason;
        uint256 passiveGross;
        uint256 referralGross;
        uint256 finalSeasonGross;
        uint256 theoreticalGross;
        uint256 payableGross;
        uint256 missedByCap;
        uint256 claimBurnAmount;
        uint256 netMintAmount;
        uint256 claimedTotalAfter;
        uint256 remainingEntitlementAfter;
    }

    struct BurnExecutionContext {
        uint256 effectiveBurnAmount;
        uint256 retainedAmount;
        uint256 newEntitlement;
        uint256 actualInputAmount;
    }

mapping(address => User) public users;
    mapping(address => bool) public isRegistered;

    mapping(address => address[]) public directReferrals;
    mapping(address => address[]) public activeDirectReferrals;
    mapping(address => bool) public hasBeenAddedToDirectList;
    mapping(address => bool) public hasBeenAddedToActiveDirectList;
    mapping(address => uint256) public activeReferralCount;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => RefOffer) public pendingOffers;

    event ProtocolNotice(string message);

    event AllowedQuoteTokenSet(address indexed token, bool indexed value);
    event AutomatedMarketMakerPairSet(address indexed pair, address indexed quoteToken);
    event TradingBurn(address indexed from, address indexed to, uint256 amount);

    event BurnExecuted(
        address indexed user,
        uint256 requestedInputAmount,
        uint256 actualInputAmount,
        uint256 effectiveBurnAmount,
        uint256 retainedAmount,
        uint256 newEntitlement,
        uint256 totalUserEntitlement,
        uint256 totalEffectiveBurnedAfter
    );

    event GiftBurnExecuted(
        address indexed payer,
        address indexed beneficiary,
        uint256 requestedInputAmount,
        uint256 actualInputAmount,
        uint256 effectiveBurnAmount,
        uint256 retainedAmount,
        uint256 newEntitlement,
        uint256 totalBeneficiaryEntitlement,
        uint256 totalEffectiveBurnedAfter
    );

    event AirdropGiftBurnExecuted(
        address indexed sponsor,
        address indexed beneficiary,
        uint256 burnAmount,
        uint256 newEntitlement,
        uint256 sponsorGiftCount,
        uint256 remainingAirdropGiftReserve,
        uint256 totalAirdropGiftBurned
    );

    event UnusedAirdropGiftReserveBurned(
        uint256 amount,
        uint256 timestamp,
        uint256 totalUnusedAirdropGiftReserveBurned
    );

    event BurnCappedToRemainingCapacity(
        address indexed user,
        uint256 requestedEffectiveBurnAmount,
        uint256 executedEffectiveBurnAmount,
        uint256 remainingCapacityBeforeBurn
    );

    event ClaimProcessed(
        address indexed user,
        bool indexed finalSeason,
        uint256 passiveGross,
        uint256 referralGross,
        uint256 finalSeasonGross,
        uint256 theoreticalGross,
        uint256 payableGross,
        uint256 missedByCap,
        uint256 claimBurnAmount,
        uint256 netMintAmount,
        uint256 claimedTotalAfter,
        uint256 remainingEntitlementAfter
    );

    event RewardMissedByCap(
        address indexed user,
        uint256 theoreticalGross,
        uint256 payableGross,
        uint256 missedAmount,
        uint256 cumulativeMissed
    );

    event RewardLimitedBySupplyCap(
        address indexed user,
        uint256 requestedGross,
        uint256 payableGrossAfterSupplyCap,
        uint256 remainingMintCapacity
    );

    event RewardBucketsSettled(
        address indexed user,
        uint256 passiveAvailable,
        uint256 passivePaid,
        uint256 passiveMissed,
        uint256 referralAvailable,
        uint256 referralPaid,
        uint256 referralMissed
    );

    event BurnClosed(uint256 timestamp, uint256 totalEffectiveBurned);
    event FinalSeasonActivated(uint256 timestamp, uint256 totalEffectiveBurned, uint256 totalRemainingGrossEntitlement);
    event FinalSeasonSnapshotTaken(address indexed user, uint256 remainingSnapshot, uint256 timestamp);

    event ReferralProposed(address indexed proposer, address indexed target);
    event ReferralAccepted(address indexed target, address indexed proposer);
    event ReferralExpired(address indexed target, address indexed proposer);
    event ReferralAssignedOnFirstBurn(address indexed user, address indexed upline);
    event DirectReferralAdded(address indexed sponsor, address indexed referral);
    event ActiveDirectReferralAdded(address indexed sponsor, address indexed referral);

    event ReferralRewardDistributed(
        address indexed sourceUser,
        address indexed recipient,
        uint256 indexed level,
        uint256 payoutPercent,
        uint256 rewardAmount,
        bool fromClaimBurn
    );

    /**
     * @param initialHolder Receives the initial 900,000 W3PI deployment allocation.
     * @param pancakeRouter_ PancakeSwap V2-compatible router address used for official AMM context.
     * @param pancakeFactory_ PancakeSwap V2-compatible factory address used for pair creation/validation.
     * @param quoteTokens_ Immutable deployment whitelist of accepted quote/base tokens.
     *
     * Example BSC mainnet whitelist candidates:
     * WBNB, USDT, USDC, BTCB, Binance-Peg ETH/WETH, CAKE, and optionally DAI/FDUSD.
     *
     * IMPORTANT:
     * Native BNB itself is not an ERC20 pair token on PancakeSwap. WBNB should be used.
     * BTC should generally be represented by BTCB on BSC.
     */
    constructor(
        address initialHolder,
        address pancakeRouter_,
        address pancakeFactory_,
        address[] memory quoteTokens_
    ) {
        require(initialHolder != address(0), "Invalid initial holder");
        require(pancakeRouter_ != address(0), "Router zero");
        require(pancakeFactory_ != address(0), "Factory zero");
        require(quoteTokens_.length > 0, "No quote tokens");

        CONTRACT_ADDRESS = address(this);
        pancakeRouter = pancakeRouter_;
        pancakeFactory = pancakeFactory_;

        for (uint256 i = 0; i < quoteTokens_.length; i++) {
            address token = quoteTokens_[i];
            require(token != address(0), "Quote zero");
            require(token != address(this), "Invalid quote");

            if (!allowedQuoteTokens[token]) {
                allowedQuoteTokens[token] = true;
                emit AllowedQuoteTokenSet(token, true);
            }
        }
        _mint(initialHolder, INITIAL_OWNER_MINT);
        _mint(CONTRACT_ADDRESS, AIRDROP_GIFT_RESERVE);
        remainingAirdropGiftReserve = AIRDROP_GIFT_RESERVE;

        emit ProtocolNotice("W3PI uses a mathematical Pi theme, but it does not guarantee USD profit, token price appreciation, liquidity, or market value.");
        emit ProtocolNotice("W3PI is not affiliated with Pi Network, Pi Coin, or any other Pi-branded blockchain, company, foundation, or project.");
        emit ProtocolNotice("The Pi reference is mathematical and symbolic: MAX_TOTAL_SUPPLY is 314,159,265 W3PI.");
        emit ProtocolNotice("Referral proposal uses 0.628318 W3PI as a 2Pi signal; acceptance returns 0.314159 W3PI, leaving about 0.314159 W3PI with the accepting wallet.");
        emit ProtocolNotice("Each preview function has its own statusCode table; frontends must not reuse status meanings across different preview functions.");
        emit ProtocolNotice("Preview functions are instant simulations only and are not reservations or execution guarantees.");
        emit ProtocolNotice("Referral proposal transfers are non-refundable symbolic network signals; expired or unused offers do not automatically return tokens to the proposer.");
        emit ProtocolNotice("Each user's gross reward entitlement is capped at 3x of effective burned tokens.");
        emit ProtocolNotice("The reward schedule is account-level: later burns join the user's original timeline and do not create separate independent Year-1 positions.");
        emit ProtocolNotice("If queued passive/referral buckets already cover remaining entitlement, skipped elapsed time is not saved for retroactive passive rewards after a later burn.");
        emit ProtocolNotice("The protocol uses a conservative mint-cap policy: if mint capacity is zero before a burn, new entitlement cannot be opened even if the burn could reduce current supply.");
        emit ProtocolNotice("Claim burns reduce net tokens received; a full 3x gross entitlement produces about 2.7x net minted tokens, not guaranteed net 3x.");
        emit ProtocolNotice("The protocol only accounts gross repayment up to 3x of effective burned tokens and does not guarantee fiat-denominated gain.");
        emit ProtocolNotice("Normal claims settle passive and referral buckets once; unpaid amounts above entitlement or supply capacity are recorded as missed, not carried as guaranteed debt.");
        emit ProtocolNotice("Maximum effective burn is Pi-adjusted to 99,415,639 W3PI; the final burn may be capped to exactly reach this limit.");
        emit ProtocolNotice("Referral rewards are bounded by MAX_TOTAL_EFFECTIVE_BURN and MAX_TOTAL_REFERRAL_PERCENT; theoretical maximum referral reward base is 49,707,819.5 W3PI, about one sixth of MAX_TOTAL_SUPPLY, before user-level and protocol caps.");
        emit ProtocolNotice("Recognized AMM buy/sell transfers apply a fixed 3% trading burn. The burn is sent to no owner, team, marketing, treasury, or liquidity wallet; it permanently reduces totalSupply.");
        emit ProtocolNotice("Trading burn can reduce long-term token-supply pressure as volume grows, but it does not guarantee price appreciation, USD value, liquidity, exchange listing, or fiat profit.");
        emit ProtocolNotice("Trading burn does not increase user burnedAmount, maxEntitlement, totalEffectiveBurned, passive rewards, claim rights, or referral rewards.");
        emit ProtocolNotice("Before final season, AMM trading burn continues normally while users can still burn W3PI and open 3x gross entitlement.");
        emit ProtocolNotice("After final season starts, AMM trading burn cannot reduce totalSupply below the Pi-aligned terminal floor of 3,141,592.65 W3PI.");
        emit ProtocolNotice("If a final-season AMM burn would cross the floor, only the amount above the floor is burned; once totalSupply is at or below the floor, AMM trading burn becomes zero.");
        emit ProtocolNotice("AMM pair registration is ownerless and permissionless, but only pairs against deployment-whitelisted quote tokens can be registered.");
        emit ProtocolNotice("MAX_TOTAL_SUPPLY is Pi-aligned at 314,159,265 W3PI; it is a hard safety cap, not a target supply or value guarantee.");
        emit ProtocolNotice("MAX_TOTAL_SUPPLY is a hard upper bound, not an expected final supply; aggressive claim-and-reburn behavior may leave realized totalSupply far below the cap.");
        emit ProtocolNotice("totalRemainingGrossEntitlement means remaining gross entitlement capacity, not guaranteed protocol debt.");
        emit ProtocolNotice("Claimed tokens are standard ERC20 tokens and may be transferred or burned again.");
        emit ProtocolNotice("Gift burns are permissionless sponsorship burns for already registered and active beneficiaries with an assigned upline.");
        emit ProtocolNotice("Gift burns spend only the payer's own tokens; the payer cannot burn the beneficiary's balance or assign/change the beneficiary's referral.");
        emit ProtocolNotice("Gift burns may increase the beneficiary's burnedAmount, entitlement, career level, active referral qualification, and existing upline referral rewards.");
        emit ProtocolNotice("Gift burns consume the same global Pi-adjusted effective burn capacity as ordinary burns; previewGiftBurnFor should be used by frontends before execution.");
        emit ProtocolNotice("Initial supply is split as 900,000 tokens to the initial holder and 100,000 tokens to the contract airdrop gift reserve.");
        emit ProtocolNotice("Airdrop gift burns are reserve-funded activation burns: one 10-token burn per beneficiary and at most five beneficiaries per eligible sponsor.");
        emit ProtocolNotice("Airdrop gift burns do not transfer free tokens; they burn reserve tokens and credit burn power/entitlement to the accepting beneficiary.");
        emit ProtocolNotice("Airdrop gift burns credit the actual reserve amount burned as burn power and are not limited by the ordinary per-wallet 99% maximum burn-input safety rule.");
        emit ProtocolNotice("If less than 10 tokens of global effective burn capacity remains, the airdrop gift burn is capped to the remaining capacity and entitlement is calculated from the actual capped amount.");
        emit ProtocolNotice("Airdrop gift burns may create referral accounting through the beneficiary's existing upline chain.");
        emit ProtocolNotice("When final season starts, unused airdrop gift reserve is burned only as supply cleanup; it creates no entitlement, referral rewards, or totalEffectiveBurned increase.");
        emit ProtocolNotice("Re-burning claimed tokens may create new entitlement, but only under the same direct effective burn, 3x gross cap, 10% virtual burn, 99% per-wallet burn-input safety limit, time-based accrual, Pi-adjusted burn cap, and MAX_TOTAL_SUPPLY rules.");
        emit ProtocolNotice("At current rates, a single account-level burn timeline reaches full 3x gross entitlement in about 21.6 months; this is token accounting, not a USD profit guarantee.");
        emit ProtocolNotice("Aggressive recursive re-burn behavior may take about 59 months, roughly 5 years, to reach the effective burn cap and complete final-season distribution.");
        emit ProtocolNotice("A slower full-cycle recursive re-burn path may take about 128 months, roughly 10.7 years, assuming each account-level reward cycle reaches full 3x gross entitlement before re-burning.");
        emit ProtocolNotice("If users delay claims, do not re-burn, or stop interacting, there is no guaranteed maximum completion time.");
        emit ProtocolNotice("Recursive re-burn behavior is an intentional long-term economic design risk and may reduce circulating supply over time.");
    }

    // ===== BEP20 =====

    function getOwner() external pure override returns (address) {
        return address(0);
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner_, address spender) external view override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        address spender = _msgSender();
        uint256 currentAllowance = _allowances[sender][spender];
        require(currentAllowance >= amount, "Allowance exceeded");
        unchecked {
            _approve(sender, spender, currentAllowance - amount);
        }
        _transfer(sender, recipient, amount);
        return true;
    }

    // ===== External user functions =====

    /// @dev Burn input is recorded directly as effective burn. Entitlement is computed from effective burn only.
    function burnWithOptionalReferral(uint256 amount, address upline) external returns (bool) {
        _handleBurnWithReferral(_msgSender(), amount, upline);
        return true;
    }

    /// @dev Use this after referral is already assigned or for genesis burn flow.
    function burn(uint256 amount) external returns (bool) {
        _handleBurnWithReferral(_msgSender(), amount, address(0));
        return true;
    }

    /// @dev Permissionless sponsorship burn. Burns the caller's own tokens and assigns the
    ///      resulting burn power/entitlement to an already registered and active beneficiary.
    ///      This function cannot burn the beneficiary's balance and cannot create, assign,
    ///      or change the beneficiary's referral. Referral rewards are routed through the
    ///      beneficiary's existing upline chain. Gift burns may help the beneficiary reach
    ///      active referral thresholds and consume the same global effective burn capacity
    ///      as ordinary burns. Frontends should call previewGiftBurnFor before execution.
    function giftBurnFor(address beneficiary, uint256 amount) external returns (bool) {
        _handleGiftBurn(_msgSender(), beneficiary, amount);
        return true;
    }

    /// @dev Only 90% of gross claim is minted. Gross still counts toward the 3x cap.
    /// @dev Claimed tokens are ordinary ERC20 tokens. If users later burn them again, they can
    ///      create new entitlement only through the same normal burn rules and global caps.
    function claim() external nonReentrant returns (bool) {
        _syncFinalSeason();

        if (finalSeasonStarted) {
            _processFinalSeasonClaim(_msgSender());
        } else {
            _processNormalClaim(_msgSender());
        }

        return true;
    }

    /// @dev Referral proposals are normal-phase only. Frontends must disable this action
    ///      when burnClosed or finalSeasonStarted is true. The proposer must already be
    ///      registered and active under the referral rules. The proposal transfer is a
    ///      non-refundable symbolic network signal: if the target does not accept or enters
    ///      through another referral path, the sent amount remains with the target.
    function proposeReferral(address target) external returns (bool) {
        _handleRefProposal(_msgSender(), target, REF_PROPOSE_AMOUNT);
        return true;
    }

    /// @dev Referral acceptance is normal-phase only. Frontends must disable this action
    ///      when burnClosed or finalSeasonStarted is true. Accepting a referral may trigger
    ///      the one-time reserve-funded airdrop activation burn if all conditions are met.
    function acceptReferral(address proposer) external returns (bool) {
        _handleRefAcceptance(_msgSender(), proposer, REF_ACCEPT_AMOUNT);
        return true;
    }

    function syncFinalSeason() external returns (bool) {
        _syncFinalSeason();
        return finalSeasonStarted;
    }

    function canAssignReferral(address account) external view returns (bool) {
        return users[account].upline == address(0) && users[account].burnedAmount == 0;
    }


    // ===== Ownerless AMM pair registration =====

    /**
     * @notice Creates or registers a PancakeSwap V2-compatible pair for W3PI and an allowed quote token.
     * @dev Anyone may call this function. It is intentionally permissionless.
     *
     * Security model:
     * - quoteToken must be in the immutable allowedQuoteTokens whitelist created at deployment.
     * - Arbitrary ABC tokens cannot be registered unless they were explicitly whitelisted at deployment.
     * - If the pair does not exist, it is created through the configured Pancake factory.
     * - The resulting pair is validated to contain both W3PI and quoteToken.
     *
     * Once registered, transfers from or to that pair are treated as AMM trading transfers and
     * the fixed 3% trading burn applies. Liquidity additions/removals that move W3PI into or
     * out of a registered pair may also experience the same fee-on-transfer behavior because
     * they are indistinguishable from pair transfers at ERC20 transfer level.
     */
    function createAndRegisterPair(address quoteToken) external returns (address pair) {
        require(allowedQuoteTokens[quoteToken], "Quote token not allowed");
        require(quoteToken != address(0), "Quote zero");
        require(quoteToken != address(this), "Invalid quote");

        pair = IPancakeFactory(pancakeFactory).getPair(address(this), quoteToken);

        if (pair == address(0)) {
            pair = IPancakeFactory(pancakeFactory).createPair(address(this), quoteToken);
        }

        _registerValidatedPair(pair, quoteToken);
    }

    function _registerValidatedPair(address pair, address quoteToken) internal {
        require(pair != address(0), "Pair zero");
        require(!automatedMarketMakerPairs[pair], "Pair already registered");

        address token0 = IPancakePair(pair).token0();
        address token1 = IPancakePair(pair).token1();

        require(token0 == address(this) || token1 == address(this), "Not W3PI pair");
        require(token0 == quoteToken || token1 == quoteToken, "Invalid quote pair");

        automatedMarketMakerPairs[pair] = true;
        emit AutomatedMarketMakerPairSet(pair, quoteToken);
    }

    function isRecognizedTradingPair(address pair) external view returns (bool) {
        return automatedMarketMakerPairs[pair];
    }

    /**
     * @notice Returns the maximum amount that can be burned from an account in a single
     *         normal burn or gift-burn payer transaction.
     * @dev The entered burn amount is direct effective burn. This helper only applies the
     *      UX/safety rule that one transaction cannot burn more than 99% of the payer's
     *      current W3PI balance. AMM trading burns and reserve-funded airdrop activation
     *      burns are not governed by this helper.
     */
    function maxBurnableBalanceOf(address account) public view returns (uint256) {
        return (_balances[account] * MAX_SINGLE_BURN_BALANCE_BPS) / BPS_DENOMINATOR;
    }

    function getBurnInputPolicy(address account)
        external
        view
        returns (
            uint256 burnEffectiveBps,
            uint256 maxSingleBurnBalanceBps,
            uint256 accountBalance,
            uint256 maxBurnableAmount
        )
    {
        burnEffectiveBps = BURN_EFFECTIVE_BPS;
        maxSingleBurnBalanceBps = MAX_SINGLE_BURN_BALANCE_BPS;
        accountBalance = _balances[account];
        maxBurnableAmount = (accountBalance * MAX_SINGLE_BURN_BALANCE_BPS) / BPS_DENOMINATOR;
    }

    // ===== Burn core =====

    function _handleBurnWithReferral(address sender, uint256 amount, address upline) internal {
        require(!burnClosed, "Burn closed");
        require(_remainingMintCapacity() > 0, "No mint capacity left");

        BurnExecutionContext memory burnCtx = _prepareBurnExecution(sender, amount);

        _validateReferralForBurn(sender, upline, burnCtx.effectiveBurnAmount);

        // Any token balance can be burned through this function, including previously claimed tokens.
        // Such re-burns are intentionally allowed but remain subject to the same entitlement,
        // time-accrual, total effective burn, and hard supply cap rules.
        // In the final capped burn, the user may request a larger amount than the remaining
        // effective burn capacity. Only the actual executable amount is burned and recorded.
        _executeBurn(
            sender,
            amount,
            burnCtx.actualInputAmount,
            burnCtx.effectiveBurnAmount,
            burnCtx.retainedAmount,
            burnCtx.newEntitlement
        );
        _syncFinalSeason();
    }

    function _handleGiftBurn(address payer, address beneficiary, uint256 amount) internal {
        require(!burnClosed, "Burn closed");
        require(_remainingMintCapacity() > 0, "No mint capacity left");
        require(beneficiary != address(0), "Invalid beneficiary");
        require(beneficiary != CONTRACT_ADDRESS, "Invalid beneficiary");
        require(beneficiary != BURN_ADDRESS, "Invalid beneficiary");
        require(beneficiary != payer, "Use normal burn");

        // Gift burns are permissionless but only allowed for users who have already entered
        // the referral graph. The payer cannot assign or change the beneficiary's referral,
        // and only the payer's own token balance can be burned.
        User storage beneficiaryUser = users[beneficiary];
        require(isRegistered[beneficiary], "Beneficiary not registered");
        require(beneficiaryUser.upline != address(0), "Beneficiary has no upline");
        require(beneficiaryUser.burnedAmount >= MIN_BURN_AMOUNT, "Beneficiary not active");

        BurnExecutionContext memory burnCtx = _prepareBurnExecution(payer, amount);

        _executeGiftBurn(
            payer,
            beneficiary,
            amount,
            burnCtx.actualInputAmount,
            burnCtx.effectiveBurnAmount,
            burnCtx.retainedAmount,
            burnCtx.newEntitlement
        );
        _syncFinalSeason();
    }

    function _prepareBurnExecution(address payer, uint256 amount)
        internal
        returns (BurnExecutionContext memory burnCtx)
    {
        (burnCtx.effectiveBurnAmount, burnCtx.retainedAmount, burnCtx.newEntitlement) = _previewBurnInternal(amount);

        uint256 totalBurnedBefore = totalEffectiveBurned;
        uint256 remainingEffectiveBurnCapacity = MAX_TOTAL_EFFECTIVE_BURN - totalBurnedBefore;
        require(remainingEffectiveBurnCapacity > 0, "No effective burn capacity left");

        bool cappedToRemainingCapacity = false;
        uint256 requestedEffectiveBurnAmount = burnCtx.effectiveBurnAmount;

        if (burnCtx.effectiveBurnAmount > remainingEffectiveBurnCapacity) {
            burnCtx.effectiveBurnAmount = remainingEffectiveBurnCapacity;
            // In a capped final burn, only the remaining executable effective amount is used.
            // The oversized requested amount is not treated as actual input. This keeps
            // event/UI accounting from showing a misleading huge retained amount.
            burnCtx.retainedAmount = 0;
            burnCtx.newEntitlement = burnCtx.effectiveBurnAmount * ENTITLEMENT_MULTIPLIER;
            cappedToRemainingCapacity = true;
        }

        // Normal burns must satisfy the minimum burn amount. The last capped burn is allowed
        // below MIN_BURN_AMOUNT so the protocol can reach exactly MAX_TOTAL_EFFECTIVE_BURN.
        // The amount entered is direct effective burn, but the actually executed burn input
        // cannot exceed 99% of the payer's current balance. This prevents accidental
        // full-balance burns while keeping reward accounting direct and easy to understand.
        burnCtx.actualInputAmount = cappedToRemainingCapacity ? burnCtx.effectiveBurnAmount : amount;
        uint256 payerBalance = _balances[payer];
        uint256 maxBurnableFromBalance = (payerBalance * MAX_SINGLE_BURN_BALANCE_BPS) / BPS_DENOMINATOR;

        if (!cappedToRemainingCapacity) {
            require(burnCtx.effectiveBurnAmount >= MIN_BURN_AMOUNT, "Burn amount below minimum");
            require(payerBalance >= burnCtx.actualInputAmount, "Insufficient balance");
            require(burnCtx.actualInputAmount <= maxBurnableFromBalance, "Amount exceeds max burnable balance");
        } else {
            require(burnCtx.effectiveBurnAmount > 0, "No effective burn capacity left");
            require(payerBalance >= burnCtx.actualInputAmount, "Insufficient balance");
            require(burnCtx.actualInputAmount <= maxBurnableFromBalance, "Amount exceeds max burnable balance");
            emit BurnCappedToRemainingCapacity(
                payer,
                requestedEffectiveBurnAmount,
                burnCtx.effectiveBurnAmount,
                remainingEffectiveBurnCapacity
            );
        }

        require(
            totalBurnedBefore + burnCtx.effectiveBurnAmount <= MAX_TOTAL_EFFECTIVE_BURN,
            "Max total effective burn exceeded"
        );
    }

    function _validateReferralForBurn(address sender, address upline, uint256 effectiveBurnAmount) internal {
        User storage user = users[sender];
        address currentUpline = user.upline;
        uint256 currentBurnedAmount = user.burnedAmount;
        uint256 totalBurnedBefore = totalEffectiveBurned;

        if (currentUpline == address(0) && currentBurnedAmount == 0) {
            if (totalBurnedBefore == 0) {
                require(upline == address(0), "First burn must be referral-free");
                require(effectiveBurnAmount >= MIN_REFERRAL_BURN, "Genesis burn below 100 W3PI");
                isRegistered[sender] = true;
            } else {
                require(upline != address(0), "Referral required");
                _assignReferralOnFirstBurn(sender, upline);
            }
        } else if (currentUpline != address(0)) {
            require(upline == address(0) || upline == currentUpline, "Referral already assigned");
        } else {
            require(upline == address(0), "Genesis burner cannot assign retroactive referral");
        }
    }

    function _executeGiftBurn(
        address payer,
        address beneficiary,
        uint256 requestedInputAmount,
        uint256 actualInputAmount,
        uint256 effectiveBurnAmount,
        uint256 retainedAmount,
        uint256 newEntitlement
    ) internal {
        User storage user = users[beneficiary];

        // Settle the beneficiary's passive rewards using the old burnedAmount before the
        // gifted burn increases the beneficiary's burn power. This prevents a retroactive
        // reward increase from a third-party gift burn.
        _settlePassiveReward(beneficiary);

        // The actual effective burn amount is removed from the payer wallet. The retainedAmount
        // event field remains zero under the direct-effective burn model.
        unchecked {
            _balances[payer] -= effectiveBurnAmount;
            _totalSupply -= effectiveBurnAmount;
            user.burnedAmount += effectiveBurnAmount;
            user.maxEntitlement += newEntitlement;
        }

        if (user.rewardStartTimestamp == 0) {
            user.rewardStartTimestamp = block.timestamp;
        }
        if (user.lastClaimTimestamp == 0) {
            user.lastClaimTimestamp = block.timestamp;
        }

        unchecked {
            totalEffectiveBurned += effectiveBurnAmount;
            totalEntitlementIssued += newEntitlement;
            totalRemainingGrossEntitlement += newEntitlement;
        }

        // Gift burns intentionally count toward the beneficiary's burnedAmount and may help
        // the beneficiary become an active referral once MIN_REFERRAL_BURN is reached.
        address upline = user.upline;
        if (
            upline != address(0) &&
            user.burnedAmount >= MIN_REFERRAL_BURN &&
            !hasBeenAddedToActiveDirectList[beneficiary]
        ) {
            activeDirectReferrals[upline].push(beneficiary);
            unchecked {
                activeReferralCount[upline] += 1;
            }
            hasBeenAddedToActiveDirectList[beneficiary] = true;
            emit ActiveDirectReferralAdded(upline, beneficiary);
        }

        emit GiftBurnExecuted(
            payer,
            beneficiary,
            requestedInputAmount,
            actualInputAmount,
            effectiveBurnAmount,
            retainedAmount,
            newEntitlement,
            user.maxEntitlement,
            totalEffectiveBurned
        );
        emit Transfer(payer, address(0), effectiveBurnAmount);

        if (!finalSeasonStarted) {
            _distributeReferralRewards(beneficiary, effectiveBurnAmount, false);
        }

        if (totalEffectiveBurned >= MAX_TOTAL_EFFECTIVE_BURN && !burnClosed) {
            burnClosed = true;
            burnCloseTimestamp = block.timestamp;
            emit BurnClosed(block.timestamp, totalEffectiveBurned);
        }
    }

    function _executeBurn(
        address sender,
        uint256 requestedInputAmount,
        uint256 actualInputAmount,
        uint256 effectiveBurnAmount,
        uint256 retainedAmount,
        uint256 newEntitlement
    ) internal {
        User storage user = users[sender];

        // IMPORTANT:
        // Settle passive rewards with the OLD burnedAmount before increasing burnedAmount.
        // This closes the retroactive oversized-claim exploit.
        //
        // Design decision:
        // Existing pendingPassiveGross and refRewards are intentionally NOT cleared here.
        // If a user burns again before claiming, those existing buckets may be settled
        // against the newly opened entitlement. This is an explicit economic choice.
        _settlePassiveReward(sender);

        // The actual effective burn amount is removed from the wallet. The retainedAmount
        // event field remains zero under the direct-effective burn model.
        unchecked {
            _balances[sender] -= effectiveBurnAmount;
            _totalSupply -= effectiveBurnAmount;
            user.burnedAmount += effectiveBurnAmount;
            user.maxEntitlement += newEntitlement;
        }

        if (user.rewardStartTimestamp == 0) {
            user.rewardStartTimestamp = block.timestamp;
        }
        if (user.lastClaimTimestamp == 0) {
            user.lastClaimTimestamp = block.timestamp;
        }

        unchecked {
            totalEffectiveBurned += effectiveBurnAmount;
            totalEntitlementIssued += newEntitlement;
            totalRemainingGrossEntitlement += newEntitlement;
        }

        address upline = user.upline;
        if (
            upline != address(0) &&
            user.burnedAmount >= MIN_REFERRAL_BURN &&
            !hasBeenAddedToActiveDirectList[sender]
        ) {
            activeDirectReferrals[upline].push(sender);
            unchecked {
                activeReferralCount[upline] += 1;
            }
            hasBeenAddedToActiveDirectList[sender] = true;
            emit ActiveDirectReferralAdded(upline, sender);
        }

        emit BurnExecuted(
            sender,
            requestedInputAmount,
            actualInputAmount,
            effectiveBurnAmount,
            retainedAmount,
            newEntitlement,
            user.maxEntitlement,
            totalEffectiveBurned
        );
        emit Transfer(sender, address(0), effectiveBurnAmount);

        if (!finalSeasonStarted) {
            _distributeReferralRewards(sender, effectiveBurnAmount, false);
        }

        if (totalEffectiveBurned >= MAX_TOTAL_EFFECTIVE_BURN && !burnClosed) {
            burnClosed = true;
            burnCloseTimestamp = block.timestamp;
            emit BurnClosed(block.timestamp, totalEffectiveBurned);
        }
    }

    // ===== Normal claim =====

    /// @dev Passive and referral are calculated separately but claimed in one transaction.
    /// @dev Settlement policy is explicit and final for this claim window:
    ///      - pendingPassiveGross + live passive are treated as the passive bucket.
    ///      - refRewards is treated as the referral bucket.
    ///      - payableGross consumes passive first, then referral.
    ///      - any unpaid amount caused by the 3x entitlement cap or supply/mint cap is recorded
    ///        as missed and is not carried as a future guaranteed claim after this claim call.
    ///      - normal-phase missed amounts are reporting/incentive records; only payableGross
    ///        consumes claimedTotal in normal phase because the account can still continue
    ///        burning, receiving referral accounting, and accruing before final season.
    ///      - final season uses a stricter closing-settlement rule: the whole unlocked
    ///        finalSeasonGross is settled, so payable and missed portions both consume
    ///        gross entitlement capacity there.
    ///      - if payableGross is zero while buckets exist, the function does not revert;
    ///        it clears the buckets into missedRewardsDueToCap and emits settlement events.
    ///      - if the user burns again BEFORE calling claim, existing buckets are intentionally
    ///        allowed to be paid against the newly opened entitlement.
    function _processNormalClaim(address sender) internal {
        User storage user = users[sender];
        require(user.burnedAmount >= MIN_BURN_AMOUNT, "Burn first");

        NormalClaimContext memory ctx;
        uint256 livePassiveGross = _calculatePassiveReward(sender);
        ctx.passiveGross = user.pendingPassiveGross + livePassiveGross;
        ctx.referralGross = user.refRewards;
        ctx.theoreticalGross = ctx.passiveGross + ctx.referralGross;

        require(ctx.theoreticalGross > 0, "No reward");

        uint256 remainingEntitlementBefore = _remainingEntitlement(sender);
        ctx.payableGross = ctx.theoreticalGross > remainingEntitlementBefore
            ? remainingEntitlementBefore
            : ctx.theoreticalGross;

        ctx.payableGross = _limitGrossByMintCapacity(sender, ctx.theoreticalGross, ctx.payableGross);

        if (ctx.payableGross == 0) {
            _settleZeroPayableNormalClaim(sender, ctx);
            return;
        }

        _settlePayableNormalClaim(sender, ctx);
    }

    function _settleZeroPayableNormalClaim(
        address sender,
        NormalClaimContext memory ctx
    ) internal {
        User storage user = users[sender];
        uint256 fullMissedByCap = ctx.theoreticalGross;

        user.missedRewardsDueToCap += fullMissedByCap;

        emit RewardMissedByCap(
            sender,
            ctx.theoreticalGross,
            0,
            fullMissedByCap,
            user.missedRewardsDueToCap
        );

        emit RewardBucketsSettled(
            sender,
            ctx.passiveGross,
            0,
            ctx.passiveGross,
            ctx.referralGross,
            0,
            ctx.referralGross
        );

        // No entitlement or mint capacity is currently available.
        // The buckets are deliberately cleared and recorded as missed instead of
        // reverting and leaving old rewards claimable after a later burn.
        user.pendingPassiveGross = 0;
        user.refRewards = 0;
        user.lastClaimTimestamp = block.timestamp;

        ClaimEventContext memory eventCtx;
        eventCtx.isFinalSeason = false;
        eventCtx.passiveGross = ctx.passiveGross;
        eventCtx.referralGross = ctx.referralGross;
        eventCtx.finalSeasonGross = 0;
        eventCtx.theoreticalGross = ctx.theoreticalGross;
        eventCtx.payableGross = 0;
        eventCtx.missedByCap = fullMissedByCap;
        eventCtx.claimBurnAmount = 0;
        eventCtx.netMintAmount = 0;
        eventCtx.claimedTotalAfter = user.claimedTotal;
        eventCtx.remainingEntitlementAfter = _remainingEntitlement(sender);

        _emitClaimProcessed(sender, eventCtx);
    }

    function _settlePayableNormalClaim(
        address sender,
        NormalClaimContext memory ctx
    ) internal {
        User storage user = users[sender];

        uint256 passivePaid = ctx.passiveGross > ctx.payableGross ? ctx.payableGross : ctx.passiveGross;
        uint256 referralPaid;
        unchecked {
            referralPaid = ctx.payableGross - passivePaid;
        }

        uint256 passiveMissed;
        uint256 referralMissed;
        uint256 missedByCap;
        unchecked {
            passiveMissed = ctx.passiveGross - passivePaid;
            referralMissed = ctx.referralGross - referralPaid;
            missedByCap = passiveMissed + referralMissed;
        }

        if (missedByCap > 0) {
            unchecked {
                user.missedRewardsDueToCap += missedByCap;
            }
            emit RewardMissedByCap(
                sender,
                ctx.theoreticalGross,
                ctx.payableGross,
                missedByCap,
                user.missedRewardsDueToCap
            );
        }

        emit RewardBucketsSettled(
            sender,
            ctx.passiveGross,
            passivePaid,
            passiveMissed,
            ctx.referralGross,
            referralPaid,
            referralMissed
        );

        // Clear both buckets. Any unpaid part above the active entitlement/supply capacity is
        // intentionally classified as missed. It can be surfaced by the UI as a burn incentive,
        // but it is not a debt that remains payable after this claim attempt.
        user.pendingPassiveGross = 0;
        user.refRewards = 0;
        user.lastClaimTimestamp = block.timestamp;

        uint256 claimBurnAmount = (ctx.payableGross * CLAIM_BURN_BPS) / BPS_DENOMINATOR;
        uint256 netMintAmount;
        unchecked {
            netMintAmount = ctx.payableGross - claimBurnAmount;
            user.claimedTotal += ctx.payableGross;
            totalRemainingGrossEntitlement -= ctx.payableGross;
        }

        _mint(sender, netMintAmount);

        // In normal phase only, the virtual burn base of claim continues referral distribution.
        if (claimBurnAmount > 0) {
            _distributeReferralRewards(sender, claimBurnAmount, true);
        }

        ClaimEventContext memory eventCtx;
        eventCtx.isFinalSeason = false;
        eventCtx.passiveGross = ctx.passiveGross;
        eventCtx.referralGross = ctx.referralGross;
        eventCtx.finalSeasonGross = 0;
        eventCtx.theoreticalGross = ctx.theoreticalGross;
        eventCtx.payableGross = ctx.payableGross;
        eventCtx.missedByCap = missedByCap;
        eventCtx.claimBurnAmount = claimBurnAmount;
        eventCtx.netMintAmount = netMintAmount;
        eventCtx.claimedTotalAfter = user.claimedTotal;
        eventCtx.remainingEntitlementAfter = _remainingEntitlement(sender);

        _emitClaimProcessed(sender, eventCtx);
    }

    // ===== Final season =====

    function _syncFinalSeason() internal {
        if (!finalSeasonStarted && burnClosed) {
            finalSeasonStarted = true;
            finalSeasonStartTimestamp = block.timestamp;

            // Final season disables new referral acceptance and airdrop activation burns.
            // Any unused airdrop gift reserve is burned only as supply cleanup. This burn
            // does not create user entitlement, does not create referral rewards, and does
            // not increase totalEffectiveBurned. It only reduces totalSupply, keeping the
            // Pi-aligned 314,159,265 W3PI hard cap conservative and never exceeding it.
            _burnUnusedAirdropGiftReserve();

            emit FinalSeasonActivated(block.timestamp, totalEffectiveBurned, totalRemainingGrossEntitlement);
        }
    }

    function _burnUnusedAirdropGiftReserve() internal {
        uint256 reserveAmount = remainingAirdropGiftReserve;
        if (reserveAmount == 0) return;

        uint256 contractBalance = _balances[CONTRACT_ADDRESS];
        uint256 burnAmount = reserveAmount > contractBalance ? contractBalance : reserveAmount;

        // Close the airdrop reserve even if the contract balance is unexpectedly lower.
        // This prevents any later airdrop gift accounting after final season activation.
        remainingAirdropGiftReserve = 0;

        if (burnAmount == 0) return;

        unchecked {
            _balances[CONTRACT_ADDRESS] = contractBalance - burnAmount;
            _totalSupply -= burnAmount;
            totalUnusedAirdropGiftReserveBurned += burnAmount;
        }

        emit Transfer(CONTRACT_ADDRESS, address(0), burnAmount);
        emit UnusedAirdropGiftReserveBurned(
            burnAmount,
            block.timestamp,
            totalUnusedAirdropGiftReserveBurned
        );
    }

    function _snapshotUserForFinalSeason(address account) internal {
        if (!finalSeasonStarted) return;

        User storage user = users[account];
        if (user.finalSeasonSnapshotted) return;

        uint256 remaining = _remainingEntitlement(account);

        user.finalSeasonRemainingSnapshot = remaining;
        user.finalSeasonClaimedFromSnapshot = 0;
        user.finalSeasonClaimTimestamp = finalSeasonStartTimestamp;
        user.finalSeasonSnapshotted = true;

        // Final season no longer uses separately claimable normal-phase accrual or referral buckets.
        user.refRewards = 0;
        user.pendingPassiveGross = 0;
        user.lastClaimTimestamp = finalSeasonStartTimestamp;

        emit FinalSeasonSnapshotTaken(account, remaining, block.timestamp);
    }

    /// @dev In final season, normal passive accrual is fully stopped and no new referral rewards are distributed.
    function _processFinalSeasonClaim(address sender) internal {
        User storage user = users[sender];

        _snapshotUserForFinalSeason(sender);

        uint256 finalSeasonGross = _calculateFinalSeasonClaimable(sender);
        require(finalSeasonGross > 0, "No reward");

        uint256 payableGross = _limitGrossByMintCapacity(sender, finalSeasonGross, finalSeasonGross);

        if (payableGross == 0) {
            _settleZeroPayableFinalSeasonClaim(sender, finalSeasonGross);
            return;
        }

        uint256 claimBurnAmount = (payableGross * CLAIM_BURN_BPS) / BPS_DENOMINATOR;
        uint256 netMintAmount = payableGross - claimBurnAmount;

        uint256 missedByCap = finalSeasonGross - payableGross;

        // The entire unlocked final-season gross amount is settled in this claim window.
        // payableGross is minted, while missedByCap is recorded as missed and must not
        // become claimable again in a later final-season claim.
        user.finalSeasonClaimedFromSnapshot += finalSeasonGross;
        user.finalSeasonClaimTimestamp = _getFinalSeasonEffectiveNow();

        // In final season, the whole unlocked gross amount is settled in this window.
        // payableGross is paid, missedByCap is recorded as missed, and both consume
        // the user's 3x gross entitlement capacity so missed amounts cannot remain
        // visible as future claimable entitlement.
        user.claimedTotal += finalSeasonGross;

        if (totalRemainingGrossEntitlement >= finalSeasonGross) {
            totalRemainingGrossEntitlement -= finalSeasonGross;
        } else {
            totalRemainingGrossEntitlement = 0;
        }

        _mint(sender, netMintAmount);
        if (missedByCap > 0) {
            user.missedRewardsDueToCap += missedByCap;
            emit RewardMissedByCap(
                sender,
                finalSeasonGross,
                payableGross,
                missedByCap,
                user.missedRewardsDueToCap
            );
        }

        ClaimEventContext memory eventCtx;
        eventCtx.isFinalSeason = true;
        eventCtx.passiveGross = 0;
        eventCtx.referralGross = 0;
        eventCtx.finalSeasonGross = finalSeasonGross;
        eventCtx.theoreticalGross = finalSeasonGross;
        eventCtx.payableGross = payableGross;
        eventCtx.missedByCap = missedByCap;
        eventCtx.claimBurnAmount = claimBurnAmount;
        eventCtx.netMintAmount = netMintAmount;
        eventCtx.claimedTotalAfter = user.claimedTotal;
        eventCtx.remainingEntitlementAfter = _remainingEntitlement(sender);

        _emitClaimProcessed(sender, eventCtx);
    }

    function _settleZeroPayableFinalSeasonClaim(
        address sender,
        uint256 finalSeasonGross
    ) internal {
        User storage user = users[sender];

        // Final season is a closing settlement phase. If mint capacity is zero,
        // the unlocked gross amount must still be closed as missed instead of
        // reverting and leaving the final-season claim window permanently open.
        user.finalSeasonClaimedFromSnapshot += finalSeasonGross;
        user.finalSeasonClaimTimestamp = _getFinalSeasonEffectiveNow();

        // The whole unlocked gross amount consumes the user's gross entitlement.
        // Nothing is minted here, but the amount is recorded as missed and cannot
        // become claimable again in a later final-season claim.
        user.claimedTotal += finalSeasonGross;

        if (totalRemainingGrossEntitlement >= finalSeasonGross) {
            totalRemainingGrossEntitlement -= finalSeasonGross;
        } else {
            totalRemainingGrossEntitlement = 0;
        }

        user.missedRewardsDueToCap += finalSeasonGross;

        emit RewardMissedByCap(
            sender,
            finalSeasonGross,
            0,
            finalSeasonGross,
            user.missedRewardsDueToCap
        );

        ClaimEventContext memory eventCtx;
        eventCtx.isFinalSeason = true;
        eventCtx.passiveGross = 0;
        eventCtx.referralGross = 0;
        eventCtx.finalSeasonGross = finalSeasonGross;
        eventCtx.theoreticalGross = finalSeasonGross;
        eventCtx.payableGross = 0;
        eventCtx.missedByCap = finalSeasonGross;
        eventCtx.claimBurnAmount = 0;
        eventCtx.netMintAmount = 0;
        eventCtx.claimedTotalAfter = user.claimedTotal;
        eventCtx.remainingEntitlementAfter = _remainingEntitlement(sender);

        _emitClaimProcessed(sender, eventCtx);
    }

    function _emitClaimProcessed(address sender, ClaimEventContext memory eventCtx) internal {
        emit ClaimProcessed(
            sender,
            eventCtx.isFinalSeason,
            eventCtx.passiveGross,
            eventCtx.referralGross,
            eventCtx.finalSeasonGross,
            eventCtx.theoreticalGross,
            eventCtx.payableGross,
            eventCtx.missedByCap,
            eventCtx.claimBurnAmount,
            eventCtx.netMintAmount,
            eventCtx.claimedTotalAfter,
            eventCtx.remainingEntitlementAfter
        );
    }

    // ===== Reward math =====

    function _settlePassiveReward(address account) internal {
        if (finalSeasonStarted) return;

        User storage user = users[account];
        uint256 burnedAmount = user.burnedAmount;
        uint256 rewardStartTimestamp = user.rewardStartTimestamp;
        uint256 lastClaimTimestamp = user.lastClaimTimestamp;

        if (
            burnedAmount == 0 ||
            rewardStartTimestamp == 0 ||
            lastClaimTimestamp == 0
        ) {
            return;
        }

        if (block.timestamp <= lastClaimTimestamp) {
            return;
        }

        uint256 accrued = _calculateRewardSegmented(
            burnedAmount,
            rewardStartTimestamp,
            lastClaimTimestamp,
            block.timestamp
        );

        uint256 remainingEntitlement = _remainingEntitlement(account);
        uint256 alreadyQueued = user.pendingPassiveGross + user.refRewards;

        // pendingPassiveGross and refRewards are both claim buckets that can use
        // the user's remaining gross entitlement. New passive accrual must not
        // push total queued buckets above the currently available entitlement.
        // If queued buckets already cover the remaining entitlement, elapsed time
        // is intentionally not saved for retroactive passive rewards after a later burn.
        if (alreadyQueued >= remainingEntitlement) {
            user.lastClaimTimestamp = block.timestamp;
            return;
        }

        uint256 availableForNewPassive;
        unchecked {
            availableForNewPassive = remainingEntitlement - alreadyQueued;
        }

        if (accrued > availableForNewPassive) {
            accrued = availableForNewPassive;
        }

        if (accrued > 0) {
            unchecked {
                user.pendingPassiveGross += accrued;
            }
        }

        user.lastClaimTimestamp = block.timestamp;
    }

    function _calculatePassiveReward(address account) internal view returns (uint256) {
        if (finalSeasonStarted) {
            return 0;
        }

        User storage user = users[account];
        uint256 burnedAmount = user.burnedAmount;
        uint256 rewardStartTimestamp = user.rewardStartTimestamp;
        uint256 lastClaimTimestamp = user.lastClaimTimestamp;

        if (
            burnedAmount == 0 ||
            rewardStartTimestamp == 0 ||
            lastClaimTimestamp == 0
        ) {
            return 0;
        }

        uint256 accrued = _calculateRewardSegmented(
            burnedAmount,
            rewardStartTimestamp,
            lastClaimTimestamp,
            block.timestamp
        );

        uint256 remainingEntitlement = _remainingEntitlement(account);
        return accrued > remainingEntitlement ? remainingEntitlement : accrued;
    }

    function _calculateRewardSegmented(
        uint256 principal,
        uint256 rewardStart,
        uint256 fromTime,
        uint256 toTime
    ) internal pure returns (uint256) {
        if (toTime <= fromTime) return 0;

        uint256 year1End = rewardStart + YEAR_DURATION;
        uint256 year2End = rewardStart + YEAR_DURATION * 2;
        uint256 year3End = rewardStart + YEAR_DURATION * 3;

        uint256 reward = 0;

        reward += _calculateRewardForWindow(principal, fromTime, toTime, rewardStart, year1End, MONTHLY_RATE_YEAR_1);
        reward += _calculateRewardForWindow(principal, fromTime, toTime, year1End, year2End, MONTHLY_RATE_YEAR_2);
        reward += _calculateRewardForWindow(principal, fromTime, toTime, year2End, year3End, MONTHLY_RATE_YEAR_3);
        reward += _calculateRewardForWindow(principal, fromTime, toTime, year3End, toTime, MONTHLY_RATE_YEAR_4_PLUS);

        return reward;
    }

    function _calculateRewardForWindow(
        uint256 principal,
        uint256 fromTime,
        uint256 toTime,
        uint256 windowStart,
        uint256 windowEnd,
        uint256 rateBps
    ) internal pure returns (uint256) {
        uint256 start = fromTime > windowStart ? fromTime : windowStart;
        uint256 end = toTime < windowEnd ? toTime : windowEnd;

        if (end <= start) return 0;

        return (principal * rateBps * (end - start)) / BPS_DENOMINATOR / MONTH_DURATION;
    }

    // ===== Final season math =====

    function _calculateFinalSeasonClaimable(address account) internal view returns (uint256) {
        User storage user = users[account];
        if (!user.finalSeasonSnapshotted) return 0;
        if (user.finalSeasonRemainingSnapshot == 0) return 0;

        uint256 effectiveNow = _getFinalSeasonEffectiveNow();
        if (effectiveNow <= finalSeasonStartTimestamp) return 0;

        uint256 elapsed = effectiveNow - finalSeasonStartTimestamp;
        uint256 totalUnlocked = (user.finalSeasonRemainingSnapshot * elapsed) / FINAL_SEASON_MAX_DURATION;

        if (totalUnlocked <= user.finalSeasonClaimedFromSnapshot) {
            return 0;
        }

        return totalUnlocked - user.finalSeasonClaimedFromSnapshot;
    }

    function _getFinalSeasonEffectiveNow() internal view returns (uint256) {
        if (!finalSeasonStarted) return 0;

        uint256 seasonEnd = finalSeasonStartTimestamp + FINAL_SEASON_MAX_DURATION;
        return block.timestamp < seasonEnd ? block.timestamp : seasonEnd;
    }

    // ===== Referral =====

    function _checkNoCircularReferral(address userAddr, address proposedUpline) internal view {
        address temp = proposedUpline;

        for (uint256 i = 0; i < MAX_REFERRAL_SEARCH_DEPTH && temp != address(0); ) {
            require(temp != userAddr, "Circular referral");
            temp = users[temp].upline;
            unchecked {
                i++;
            }
        }

        // The referral payout system only searches MAX_REFERRAL_SEARCH_DEPTH levels.
        // To keep the referral graph bounded and audit-friendly, the chain must
        // also terminate within the same depth. This prevents hidden cycles or
        // excessively deep referral chains beyond the payout search range.
        require(temp == address(0), "Referral chain too deep");
    }

    function _validateUpline(address upline) internal view {
        require(upline != address(0), "Invalid upline");
        require(upline != CONTRACT_ADDRESS, "Invalid upline");
        require(upline != BURN_ADDRESS, "Invalid upline");
        require(isRegistered[upline], "Upline not registered");
        require(users[upline].burnedAmount >= MIN_REFERRAL_BURN, "Upline not active");
    }
function _assignReferralOnFirstBurn(address userAddr, address upline) internal {
        User storage user = users[userAddr];
        require(user.upline == address(0), "Referral already assigned");
        require(user.burnedAmount == 0, "Referral only on first burn");
        require(upline != userAddr, "No self-referral");

        _validateUpline(upline);

        _checkNoCircularReferral(userAddr, upline);

        // If the user enters the referral tree through first burn instead of accepting
        // a pending proposal, clear any stale offer so dashboards and indexers do not
        // keep showing an unusable referral invitation. The original proposal transfer
        // is a non-refundable symbolic network signal and is not reversed here.
        address staleProposer = pendingOffers[userAddr].proposer;
        if (staleProposer != address(0)) {
            delete pendingOffers[userAddr];
            emit ReferralExpired(userAddr, staleProposer);
        }

        user.upline = upline;
        isRegistered[userAddr] = true;

        if (!hasBeenAddedToDirectList[userAddr]) {
            directReferrals[upline].push(userAddr);
            hasBeenAddedToDirectList[userAddr] = true;
            emit DirectReferralAdded(upline, userAddr);
        }

        emit ReferralAssignedOnFirstBurn(userAddr, upline);
    }

    function _handleRefProposal(address proposer, address target, uint256 amount) internal {
        // If the burn cap was reached by a previous operation but final season has not been
        // synchronized yet, synchronize it before processing any new referral action.
        _syncFinalSeason();
        require(!burnClosed && !finalSeasonStarted, "Referral disabled after burn cap");

        // The proposer must already be a registered and active sponsor.
        // This prevents inactive or fake accounts from sending referral offers.
        _validateUpline(proposer);

        require(proposer != target, "No self-referral");
        require(target != address(0), "Invalid target");
        require(target != CONTRACT_ADDRESS, "Invalid target");
        require(target != BURN_ADDRESS, "Invalid target");

        User storage targetUser = users[target];
        require(targetUser.upline == address(0), "Target already referred");
        require(targetUser.burnedAmount == 0, "Target already burned");

        uint256 proposerBalance = _balances[proposer];
        require(proposerBalance >= amount, "Insufficient balance");

        RefOffer memory offer = pendingOffers[target];
        if (offer.proposer != address(0)) {
            if (block.timestamp <= offer.timestamp + REF_EXPIRE_TIME) {
                revert("Active referral offer exists");
            }

            delete pendingOffers[target];
            emit ReferralExpired(target, offer.proposer);
        }

        unchecked {
            _balances[proposer] = proposerBalance - amount;
            _balances[target] += amount;
        }

        pendingOffers[target] = RefOffer(proposer, block.timestamp);

        emit Transfer(proposer, target, amount);
        emit ReferralProposed(proposer, target);
    }

    function _handleRefAcceptance(address acceptor, address proposer, uint256 amount) internal {
        // If the burn cap was reached by a previous operation but final season has not been
        // synchronized yet, synchronize it before processing any new referral action.
        _syncFinalSeason();
        require(!burnClosed && !finalSeasonStarted, "Referral disabled after burn cap");

        RefOffer memory offer = pendingOffers[acceptor];

        require(offer.proposer == proposer, "Invalid proposal");
        require(block.timestamp <= offer.timestamp + REF_EXPIRE_TIME, "Offer expired");
        require(acceptor != proposer, "No self-referral");

        User storage acceptorUser = users[acceptor];
        require(acceptorUser.upline == address(0), "Already referred");
        require(acceptorUser.burnedAmount == 0, "Referral only before first burn");

        uint256 acceptorBalance = _balances[acceptor];
        require(acceptorBalance >= amount, "Insufficient balance");

        _validateUpline(proposer);

        _checkNoCircularReferral(acceptor, proposer);

        acceptorUser.upline = proposer;
        isRegistered[acceptor] = true;

        unchecked {
            _balances[acceptor] = acceptorBalance - amount;
            _balances[proposer] += amount;
        }

        delete pendingOffers[acceptor];

        if (!hasBeenAddedToDirectList[acceptor]) {
            directReferrals[proposer].push(acceptor);
            hasBeenAddedToDirectList[acceptor] = true;
            emit DirectReferralAdded(proposer, acceptor);
        }

        emit Transfer(acceptor, proposer, amount);
        emit ReferralAccepted(acceptor, proposer);

        // If eligible, automatically apply a one-time reserve-funded airdrop gift burn
        // to help the newly referred user start with a small burn power/entitlement.
        // Referral acceptance must not fail only because the airdrop gift is unavailable.
        _processAirdropGiftBurn(proposer, acceptor);
    }

    function _processAirdropGiftBurn(address sponsor, address beneficiary) internal {
        if (!_canProcessAirdropGiftBurn(sponsor, beneficiary)) {
            return;
        }

        uint256 burnAmount = _getExecutableAirdropGiftBurnAmount();
        if (burnAmount == 0) {
            return;
        }

        uint256 newEntitlement = burnAmount * ENTITLEMENT_MULTIPLIER;

        // Settle using the beneficiary's old burnedAmount before the reserve-funded
        // activation burn increases their burn power. This keeps the same anti-retroactive
        // reward rule used by normal burns and permissionless gift burns.
        _settlePassiveReward(beneficiary);

        _applyAirdropGiftBurnState(sponsor, beneficiary, burnAmount, newEntitlement);

        emit Transfer(CONTRACT_ADDRESS, address(0), burnAmount);
        emit AirdropGiftBurnExecuted(
            sponsor,
            beneficiary,
            burnAmount,
            newEntitlement,
            sponsorAirdropGiftCount[sponsor],
            remainingAirdropGiftReserve,
            totalAirdropGiftBurned
        );

        if (!finalSeasonStarted) {
            _distributeReferralRewards(beneficiary, burnAmount, false);
        }

        if (totalEffectiveBurned >= MAX_TOTAL_EFFECTIVE_BURN && !burnClosed) {
            burnClosed = true;
            burnCloseTimestamp = block.timestamp;
            emit BurnClosed(block.timestamp, totalEffectiveBurned);
        }

        // If this airdrop gift burn closed the global effective burn cap, final season
        // must start in the same transaction and unused reserve must be cleanup-burned.
        _syncFinalSeason();
    }

    function _canProcessAirdropGiftBurn(address sponsor, address beneficiary) internal view returns (bool) {
        if (hasReceivedAirdropGift[beneficiary]) {
            return false;
        }

        if (sponsorAirdropGiftCount[sponsor] >= MAX_AIRDROP_GIFTS_PER_SPONSOR) {
            return false;
        }

        // Airdrop activation must not create new entitlement if no future mint capacity remains.
        // This returns silently so referral acceptance itself does not fail only because
        // the optional airdrop gift cannot be applied.
        if (_remainingMintCapacity() == 0) {
            return false;
        }

        if (remainingAirdropGiftReserve == 0) {
            return false;
        }

        return totalEffectiveBurned < MAX_TOTAL_EFFECTIVE_BURN;
    }

    function _getExecutableAirdropGiftBurnAmount() internal view returns (uint256 burnAmount) {
        burnAmount = AIRDROP_GIFT_BURN_AMOUNT;

        uint256 reserveRemaining = remainingAirdropGiftReserve;
        if (burnAmount > reserveRemaining) {
            burnAmount = reserveRemaining;
        }

        uint256 contractBalance = _balances[CONTRACT_ADDRESS];
        if (burnAmount > contractBalance) {
            burnAmount = contractBalance;
        }

        uint256 remainingEffectiveBurnCapacity = MAX_TOTAL_EFFECTIVE_BURN - totalEffectiveBurned;
        if (burnAmount > remainingEffectiveBurnCapacity) {
            burnAmount = remainingEffectiveBurnCapacity;
        }
    }

    function _applyAirdropGiftBurnState(
        address sponsor,
        address beneficiary,
        uint256 burnAmount,
        uint256 newEntitlement
    ) internal {
        User storage user = users[beneficiary];
        uint256 contractBalance = _balances[CONTRACT_ADDRESS];
        uint256 totalBurnedBefore = totalEffectiveBurned;
        uint256 reserveRemaining = remainingAirdropGiftReserve;
        uint256 sponsorGiftCount = sponsorAirdropGiftCount[sponsor];

        // Airdrop gift burn is a reserve-funded activation burn, not a normal 99% user burn.
        // The actual reserve amount burned is credited as the same amount of burn power.
        unchecked {
            _balances[CONTRACT_ADDRESS] = contractBalance - burnAmount;
            _totalSupply -= burnAmount;
            user.burnedAmount += burnAmount;
            user.maxEntitlement += newEntitlement;
        }

        if (user.rewardStartTimestamp == 0) {
            user.rewardStartTimestamp = block.timestamp;
        }
        if (user.lastClaimTimestamp == 0) {
            user.lastClaimTimestamp = block.timestamp;
        }

        unchecked {
            totalEffectiveBurned = totalBurnedBefore + burnAmount;
            totalEntitlementIssued += newEntitlement;
            totalRemainingGrossEntitlement += newEntitlement;
            totalAirdropGiftBurned += burnAmount;
            remainingAirdropGiftReserve = reserveRemaining - burnAmount;
            sponsorAirdropGiftCount[sponsor] = sponsorGiftCount + 1;
        }

        hasReceivedAirdropGift[beneficiary] = true;
        _maybeAddActiveDirectReferral(beneficiary, user.upline, user.burnedAmount);
    }

    function _maybeAddActiveDirectReferral(
        address referral,
        address upline,
        uint256 burnedAmount
    ) internal {
        if (
            upline != address(0) &&
            burnedAmount >= MIN_REFERRAL_BURN &&
            !hasBeenAddedToActiveDirectList[referral]
        ) {
            activeDirectReferrals[upline].push(referral);
            unchecked {
                activeReferralCount[upline] += 1;
            }
            hasBeenAddedToActiveDirectList[referral] = true;
            emit ActiveDirectReferralAdded(upline, referral);
        }
    }

    function _hasQualifiedFallbackReferral(address upline, uint256) internal view returns (bool) {
        return users[upline].burnedAmount >= 10_000 * 10**18 || activeReferralCount[upline] >= 5;
    }

    function _getReferralPercent(uint256 burned) internal pure returns (uint256) {
        if (burned >= 1_000_000 * 10**18) return 40;
        if (burned >= 100_000 * 10**18) return 35;
        if (burned >= 50_000 * 10**18) return 34;
        if (burned >= 25_000 * 10**18) return 32;
        if (burned >= 10_000 * 10**18) return 30;
        if (burned >= 5_000 * 10**18) return 28;
        if (burned >= 2_500 * 10**18) return 25;
        if (burned >= 1_000 * 10**18) return 20;
        if (burned >= 500 * 10**18) return 15;
        if (burned >= 100 * 10**18) return 10;
        return 0;
    }

    function _distributeReferralRewards(address sourceUser, uint256 burnBaseAmount, bool fromClaimBurn) internal {
        if (finalSeasonStarted || burnBaseAmount == 0) return;

        address upline = users[sourceUser].upline;
        uint256 lastPaidPercent = 0;
        uint256 distributedPercent = 0;

        for (uint256 level = 1; level <= MAX_REFERRAL_SEARCH_DEPTH && upline != address(0); ) {
            (uint256 payoutPercent, uint256 updatedLastPaidPercent) = _getReferralPayoutForUpline(
                upline,
                lastPaidPercent
            );
            lastPaidPercent = updatedLastPaidPercent;

            if (payoutPercent > 0) {
                if (distributedPercent >= MAX_TOTAL_REFERRAL_PERCENT) break;

                uint256 remainingPercent;
                unchecked {
                    remainingPercent = MAX_TOTAL_REFERRAL_PERCENT - distributedPercent;
                }
                if (payoutPercent > remainingPercent) {
                    payoutPercent = remainingPercent;
                }

                distributedPercent += _applyReferralReward(
                    sourceUser,
                    upline,
                    level,
                    payoutPercent,
                    burnBaseAmount,
                    fromClaimBurn
                );
            }

            upline = users[upline].upline;
            unchecked {
                level++;
            }
        }
    }

    function _getReferralPayoutForUpline(address upline, uint256 lastPaidPercent)
        internal
        view
        returns (uint256 payoutPercent, uint256 updatedLastPaidPercent)
    {
        updatedLastPaidPercent = lastPaidPercent;

        uint256 burned = users[upline].burnedAmount;
        if (burned < MIN_REFERRAL_BURN) {
            return (0, updatedLastPaidPercent);
        }

        uint256 currentPercent = _getReferralPercent(burned);

        if (currentPercent > lastPaidPercent) {
            unchecked {
                payoutPercent = currentPercent - lastPaidPercent;
            }
            updatedLastPaidPercent = currentPercent;
        } else if (
            currentPercent > 0 &&
            currentPercent <= lastPaidPercent &&
            _hasQualifiedFallbackReferral(upline, currentPercent)
        ) {
            payoutPercent = FALLBACK_PERCENT;
        }
    }

    function _applyReferralReward(
        address sourceUser,
        address recipient,
        uint256 level,
        uint256 payoutPercent,
        uint256 burnBaseAmount,
        bool fromClaimBurn
    ) internal returns (uint256 appliedPercent) {
        uint256 rewardAmount = (burnBaseAmount * payoutPercent) / 100;
        if (rewardAmount == 0) {
            return 0;
        }

        unchecked {
            users[recipient].refRewards += rewardAmount;
        }

        emit ReferralRewardDistributed(
            sourceUser,
            recipient,
            level,
            payoutPercent,
            rewardAmount,
            fromClaimBurn
        );

        return payoutPercent;
    }

    // ===== Supply cap payment math =====

    function _remainingMintCapacity() internal view returns (uint256) {
        uint256 supply = _totalSupply;
        uint256 minted = totalMintedSupply;

        uint256 supplyCapacity = MAX_TOTAL_SUPPLY > supply
            ? MAX_TOTAL_SUPPLY - supply
            : 0;

        uint256 mintedCapacity = MAX_TOTAL_MINTED_SUPPLY > minted
            ? MAX_TOTAL_MINTED_SUPPLY - minted
            : 0;

        return supplyCapacity < mintedCapacity ? supplyCapacity : mintedCapacity;
    }

    function _maxGrossPayableByMintCapacity() internal view returns (uint256) {
        uint256 remainingMintCapacity = _remainingMintCapacity();
        if (remainingMintCapacity == 0) return 0;

        uint256 netBps = BPS_DENOMINATOR - CLAIM_BURN_BPS;
        return (remainingMintCapacity * BPS_DENOMINATOR) / netBps;
    }

    function _limitGrossByMintCapacity(
        address account,
        uint256 requestedGross,
        uint256 payableGross
    ) internal returns (uint256) {
        uint256 remainingMintCapacity = _remainingMintCapacity();
        uint256 maxGrossBySupplyCap = remainingMintCapacity == 0
            ? 0
            : (remainingMintCapacity * BPS_DENOMINATOR) / (BPS_DENOMINATOR - CLAIM_BURN_BPS);

        if (payableGross > maxGrossBySupplyCap) {
            emit RewardLimitedBySupplyCap(
                account,
                requestedGross,
                maxGrossBySupplyCap,
                remainingMintCapacity
            );
            return maxGrossBySupplyCap;
        }

        return payableGross;
    }

    // ===== Views =====

    function _remainingEntitlement(address account) internal view returns (uint256) {
        User storage user = users[account];
        if (user.claimedTotal >= user.maxEntitlement) return 0;
        return user.maxEntitlement - user.claimedTotal;
    }


    function getUserBurnData(address account)
        external
        view
        returns (
            uint256 burnedAmount,
            address upline,
            uint256 rewardStartTimestamp,
            uint256 lastClaimTimestamp
        )
    {
        User storage user = users[account];
        return (user.burnedAmount, user.upline, user.rewardStartTimestamp, user.lastClaimTimestamp);
    }

    function getUserClaimData(address account)
        external
        view
        returns (
            uint256 refRewards,
            uint256 pendingPassiveGross,
            uint256 maxEntitlement,
            uint256 claimedTotal,
            uint256 missedRewardsDueToCap
        )
    {
        User storage user = users[account];
        return (user.refRewards, user.pendingPassiveGross, user.maxEntitlement, user.claimedTotal, user.missedRewardsDueToCap);
    }

    function getUserFinalSeasonData(address account)
        external
        view
        returns (
            uint256 finalSeasonRemainingSnapshot,
            uint256 finalSeasonClaimedFromSnapshot,
            uint256 finalSeasonClaimTimestamp,
            bool finalSeasonSnapshotted
        )
    {
        User storage user = users[account];
        return (
            user.finalSeasonRemainingSnapshot,
            user.finalSeasonClaimedFromSnapshot,
            user.finalSeasonClaimTimestamp,
            user.finalSeasonSnapshotted
        );
    }

    function getRemainingEntitlement(address account) external view returns (uint256) {
        return _remainingEntitlement(account);
    }

    function getMissedRewardsDueToCap(address account) external view returns (uint256) {
        return users[account].missedRewardsDueToCap;
    }

    function getPendingPassiveGross(address account) external view returns (uint256) {
        return users[account].pendingPassiveGross;
    }
function getFinalSeasonClaimable(address account) external view returns (uint256) {
        return _previewFinalSeasonClaimable(account);
    }

    function _previewFinalSeasonClaimable(address account) internal view returns (uint256) {
        if (!finalSeasonStarted) return 0;

        User storage user = users[account];
        if (user.finalSeasonSnapshotted) {
            return _calculateFinalSeasonClaimable(account);
        }

        uint256 remaining = _remainingEntitlement(account);
        uint256 effectiveNow = _getFinalSeasonEffectiveNow();
        if (effectiveNow <= finalSeasonStartTimestamp) return 0;

        uint256 elapsed = effectiveNow - finalSeasonStartTimestamp;
        return (remaining * elapsed) / FINAL_SEASON_MAX_DURATION;
    }

    /**
     * @dev Instant simulation for permissionless gift burns. This is a view-only preview
     *      of the current block state and is not a reservation or execution guarantee.
     *      Values may change before the transaction is mined due to other burns, claims,
     *      final-season activation, or supply/burn-cap changes.
     *
     *      Permissionless gift burn impact to show in the UI:
     *      - the payer burns only their own tokens;
     *      - the beneficiary's balance is never burned;
     *      - the beneficiary's referral cannot be assigned or changed;
     *      - burn power, entitlement, career level, and active-referral status may increase
     *        for the beneficiary;
     *      - referral accounting routes through the beneficiary's existing upline chain;
     *      - the same global effective burn cap is consumed.
     *
     * @dev Preview for permissionless gift burns.
     * statusCode values:
     * 0 = Allowed
     * 1 = Burn closed
     * 2 = Invalid beneficiary
     * 3 = Use normal burn
     * 4 = Beneficiary not registered
     * 5 = Beneficiary has no upline
     * 6 = Beneficiary not active
     * 7 = No effective burn capacity left
     * 8 = Burn amount below minimum
     * 9 = Insufficient balance
     * 10 = Zero amount
     * 11 = No mint capacity left
     * 12 = Amount exceeds max burnable balance for one transaction
     */
/**
     * @dev Instant simulation for the one-time referral-acceptance airdrop gift burn.
     *      This is not a reservation. The result may change before execution if the referral
     *      offer expires, the sponsor reaches the gift limit, the beneficiary receives a gift,
     *      the airdrop reserve changes, or the global burn cap/final season state changes.
     *
     * @dev Previews whether the one-time referral-acceptance airdrop gift burn would be available.
     * statusCode values:
     * 0 = Available
     * 1 = Final season active or burn closed
     * 2 = Sponsor not eligible
     * 3 = Beneficiary already registered/referred/burned and cannot accept a new referral
     * 4 = No active referral offer from sponsor to beneficiary
     * 5 = Beneficiary already received airdrop gift
     * 6 = Sponsor airdrop gift limit reached
     * 7 = Airdrop reserve unavailable
     * 8 = No effective burn capacity left
     * 9 = No mint capacity left
     */
/// @dev Instant simulation of referral proposal. This is view-only and not a reservation.
    ///      Each preview function has its own statusCode table; frontends should not reuse
    ///      statusCode meanings from other preview functions.
    ///
    ///      statusCode values for previewReferralProposal:
    ///      0 = Allowed
    ///      1 = Referral disabled after burn cap or final season
    ///      2 = Proposer not registered
    ///      3 = Proposer not active
    ///      4 = No self-referral
    ///      5 = Invalid target
    ///      6 = Target already referred
    ///      7 = Target already burned
    ///      8 = Insufficient proposer balance
    ///      9 = Active referral offer exists
/// @dev Instant simulation of referral acceptance. This is view-only and not a reservation.
    ///      It also reports whether the reserve-funded airdrop activation burn would currently
    ///      be available if acceptance succeeds. Each preview function has its own statusCode table;
    ///      frontends should not reuse statusCode meanings from other preview functions.
    ///
    ///      statusCode values for previewReferralAcceptance:
    ///      0  = Allowed
    ///      1  = Referral disabled after burn cap or final season
    ///      2  = Invalid proposal
    ///      3  = Offer expired
    ///      4  = No self-referral
    ///      5  = Already referred
    ///      6  = Referral only before first burn
    ///      7  = Insufficient acceptor balance
    ///      8  = Proposer not registered
    ///      9  = Proposer not active
    ///      10 = Circular referral
    ///      11 = Referral chain too deep
/// @dev Instant simulation of burn(amount) using the current global burn cap,
    ///      mint-cap state, genesis state, and caller state. This view result is not a
    ///      reservation; another transaction can change the actual executable amount before
    ///      this user's transaction is mined.
    ///
    ///      statusCode values:
    ///      0 = Allowed for burn(amount)
    ///      1 = Burn closed
    ///      2 = Zero amount
    ///      3 = No effective burn capacity left
    ///      4 = Burn amount below minimum
    ///      5 = Genesis burn below 100 W3PI
    ///      6 = No mint capacity left
    ///      7 = Insufficient balance
    ///      8 = Referral required; use burnWithOptionalReferral(amount, upline)
    ///      18 = Amount exceeds max burnable balance for one transaction
    ///
    ///      This preview is for the plain burn(amount) flow. If the user has not joined the
    ///      referral graph and the protocol is no longer at genesis, burnWithOptionalReferral
    ///      with a valid upline is required instead.
/// @dev Instant simulation of burnWithOptionalReferral(amount, upline).
    ///      This preview mirrors the referral onboarding rules without reverting for
    ///      invalid upline, circular referral, or chain-depth conditions. It is view-only
    ///      and not a reservation; state may change before the transaction is mined.
    ///
    ///      statusCode values:
    ///      0  = Allowed
    ///      1  = Burn closed
    ///      2  = Zero amount
    ///      3  = No effective burn capacity left
    ///      4  = Burn amount below minimum
    ///      5  = Genesis burn below 100 W3PI
    ///      6  = No mint capacity left
    ///      7  = Insufficient balance
    ///      8  = First burn must be referral-free
    ///      9  = Referral required
    ///      10 = Invalid upline
    ///      11 = Upline not registered
    ///      12 = Upline not active
    ///      13 = No self-referral
    ///      14 = Referral already assigned
    ///      15 = Genesis burner cannot assign retroactive referral
    ///      16 = Circular referral
    ///      17 = Referral chain too deep
    ///      18 = Amount exceeds max burnable balance for one transaction
function _previewBurnInternal(uint256 amount)
        internal
        pure
        returns (
            uint256 effectiveBurnAmount,
            uint256 retainedAmount,
            uint256 newEntitlement
        )
    {
        // Direct-effective burn model:
        // the amount entered by the user is the amount that becomes effective burn.
        // The separate maxBurnableBalanceOf() check prevents accidental full-balance burns.
        effectiveBurnAmount = amount;
        retainedAmount = 0;
        newEntitlement = effectiveBurnAmount * ENTITLEMENT_MULTIPLIER;
    }

    /// @dev Instant simulation of claimable amounts using the current entitlement, bucket,
    ///      final-season, and mint-cap state. This view result is not a reservation and
    ///      may change before the claim transaction is mined.
function getSupplyCapInfo()
        external
        view
        returns (
            uint256 currentSupply,
            uint256 maxTotalSupply,
            uint256 remainingSupplyCapacity,
            uint256 totalMinted,
            uint256 maxTotalMintedSupply,
            uint256 remainingMintedCapacity
        )
    {
        currentSupply = _totalSupply;
        maxTotalSupply = MAX_TOTAL_SUPPLY;
        remainingSupplyCapacity = MAX_TOTAL_SUPPLY > currentSupply
            ? MAX_TOTAL_SUPPLY - currentSupply
            : 0;
        totalMinted = totalMintedSupply;
        maxTotalMintedSupply = MAX_TOTAL_MINTED_SUPPLY;
        remainingMintedCapacity = MAX_TOTAL_MINTED_SUPPLY > totalMinted
            ? MAX_TOTAL_MINTED_SUPPLY - totalMinted
            : 0;
    }

    function getBurnCapInfo()
        external
        view
        returns (
            uint256 totalEffectiveBurned_,
            uint256 maxTotalEffectiveBurn,
            uint256 remainingEffectiveBurnCapacity,
            bool burnClosed_
        )
    {
        totalEffectiveBurned_ = totalEffectiveBurned;
        maxTotalEffectiveBurn = MAX_TOTAL_EFFECTIVE_BURN;
        remainingEffectiveBurnCapacity = MAX_TOTAL_EFFECTIVE_BURN > totalEffectiveBurned
            ? MAX_TOTAL_EFFECTIVE_BURN - totalEffectiveBurned
            : 0;
        burnClosed_ = burnClosed;
    }

    function getTradingBurnInfo()
        external
        view
        returns (
            uint256 tradingBurnFeeBps,
            uint256 totalTradingBurned_,
            address router,
            address factory
        )
    {
        tradingBurnFeeBps = TRADING_BURN_FEE_BPS;
        totalTradingBurned_ = totalTradingBurned;
        router = pancakeRouter;
        factory = pancakeFactory;
    }

    /**
     * @notice Returns final-season AMM burn floor information for frontends and whitepaper
     *         displays. The floor only limits AMM trading burn after final season has started.
     *         Before final season, the normal 3% AMM trading burn remains active.
     */
    function getTradingBurnFloorInfo()
        external
        view
        returns (
            uint256 tradingBurnSupplyFloor,
            bool finalSeasonFloorActive,
            uint256 currentSupply,
            uint256 burnableUntilFloor
        )
    {
        tradingBurnSupplyFloor = AMM_TRADING_BURN_SUPPLY_FLOOR;
        finalSeasonFloorActive = finalSeasonStarted;
        currentSupply = _totalSupply;
        burnableUntilFloor = currentSupply > AMM_TRADING_BURN_SUPPLY_FLOOR
            ? currentSupply - AMM_TRADING_BURN_SUPPLY_FLOOR
            : 0;
    }

    /**
     * @notice Instant simulation of the AMM trading burn fee for a W3PI transfer amount.
     *         This does not check balances, allowances, pair reserves, router slippage, or
     *         whether a specific sender/recipient is a registered AMM pair. It only previews
     *         the token-level trading-burn math for recognized AMM transfers.
     */
    function previewTradingBurnFee(uint256 amount)
        external
        view
        returns (
            uint256 requestedAmount,
            uint256 burnAmount,
            uint256 netAmount,
            bool finalSeasonFloorActive,
            bool cappedByFloor,
            uint256 supplyAfterBurn
        )
    {
        requestedAmount = amount;
        uint256 nominalBurnAmount = _calculateNominalTradingBurnFee(amount);
        burnAmount = _calculateTradingBurnFee(amount);
        netAmount = amount - burnAmount;
        finalSeasonFloorActive = finalSeasonStarted;
        cappedByFloor = finalSeasonStarted && nominalBurnAmount > burnAmount;
        supplyAfterBurn = _totalSupply > burnAmount ? _totalSupply - burnAmount : 0;
    }

    // ===== Internal token ops =====

    function _calculateNominalTradingBurnFee(uint256 amount) internal pure returns (uint256) {
        // Overflow-safe exact bps calculation for arbitrary preview inputs.
        return ((amount / BPS_DENOMINATOR) * TRADING_BURN_FEE_BPS) +
            (((amount % BPS_DENOMINATOR) * TRADING_BURN_FEE_BPS) / BPS_DENOMINATOR);
    }

    function _calculateTradingBurnFee(uint256 amount) internal view returns (uint256) {
        uint256 feeAmount = _calculateNominalTradingBurnFee(amount);

        // The Pi-aligned terminal floor is intentionally final-season only.
        // Before final season, AMM trading burn continues normally because users may still
        // burn W3PI directly and open 3x gross entitlement.
        if (!finalSeasonStarted) {
            return feeAmount;
        }

        if (_totalSupply <= AMM_TRADING_BURN_SUPPLY_FLOOR) {
            return 0;
        }

        uint256 maxBurnUntilFloor = _totalSupply - AMM_TRADING_BURN_SUPPLY_FLOOR;
        return feeAmount > maxBurnUntilFloor ? maxBurnUntilFloor : feeAmount;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");
        require(recipient != CONTRACT_ADDRESS, "Direct transfer to contract disabled");
        require(recipient != BURN_ADDRESS, "Use burn function");

        if (amount == 0) {
            emit Transfer(sender, recipient, 0);
            return;
        }

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Insufficient balance");

        bool isTradingTransfer =
            automatedMarketMakerPairs[sender] ||
            automatedMarketMakerPairs[recipient];

        if (isTradingTransfer) {
            uint256 feeAmount = (amount * TRADING_BURN_FEE_BPS) / BPS_DENOMINATOR;

            // The Pi-aligned terminal floor is intentionally final-season only.
            // Before final season, AMM trading burn continues normally because users may still
            // burn W3PI directly and open 3x gross entitlement.
            if (finalSeasonStarted) {
                uint256 supply = _totalSupply;
                if (supply <= AMM_TRADING_BURN_SUPPLY_FLOOR) {
                    feeAmount = 0;
                } else {
                    uint256 maxBurnUntilFloor;
                    unchecked {
                        maxBurnUntilFloor = supply - AMM_TRADING_BURN_SUPPLY_FLOOR;
                    }
                    if (feeAmount > maxBurnUntilFloor) {
                        feeAmount = maxBurnUntilFloor;
                    }
                }
            }

            uint256 netAmount;
            unchecked {
                netAmount = amount - feeAmount;
                _balances[sender] = senderBalance - amount;
                _balances[recipient] += netAmount;
            }

            // Buy example before the final-season floor:  pair -> user. Pair balance decreases
            //               by full amount, user receives 97%, and 3% is burned from supply.
            // Sell example before the final-season floor: user -> pair. User balance decreases
            //               by full amount, pair receives 97%, and 3% is burned from supply.
            // Liquidity example: adding W3PI to a registered pair is also a transfer to the
            //               pair, so W3PI behaves as a fee-on-transfer token for AMM operations.
            //
            // Final-season floor: after final season starts, feeAmount is capped so AMM trading
            // burn cannot reduce totalSupply below AMM_TRADING_BURN_SUPPLY_FLOOR. If totalSupply
            // is already at or below the floor, feeAmount becomes zero.
            //
            // This is NOT a protocol burn-power action. It does not call _executeBurn(),
            // does not increase burnedAmount, does not open maxEntitlement, does not
            // distribute referral rewards, and does not affect totalEffectiveBurned.
            // It only reduces totalSupply and increments totalTradingBurned when feeAmount > 0.
            if (feeAmount > 0) {
                unchecked {
                    _totalSupply -= feeAmount;
                    totalTradingBurned += feeAmount;
                }

                emit Transfer(sender, recipient, netAmount);
                emit Transfer(sender, address(0), feeAmount);
                emit TradingBurn(sender, recipient, feeAmount);
            } else {
                emit Transfer(sender, recipient, netAmount);
            }

            return;
        }

        unchecked {
            _balances[sender] = senderBalance - amount;
            _balances[recipient] += amount;
        }
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        if (amount == 0) return;

        // Hard cap: mint-on-claim cannot expand supply beyond the Pi-aligned
        // 314,159,265 W3PI maximum total supply. This cap is a conservative
        // safety boundary, not a target supply and not a price, liquidity,
        // fiat-value, or profit guarantee.
        uint256 supply = _totalSupply;
        uint256 minted = totalMintedSupply;
        require(supply + amount <= MAX_TOTAL_SUPPLY, "Max total supply exceeded");
        require(minted + amount <= MAX_TOTAL_MINTED_SUPPLY, "Max minted supply exceeded");

        unchecked {
            _balances[account] += amount;
            _totalSupply = supply + amount;
            totalMintedSupply = minted + amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "Approve from zero");
        require(spender != address(0), "Approve to zero");
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }
}
