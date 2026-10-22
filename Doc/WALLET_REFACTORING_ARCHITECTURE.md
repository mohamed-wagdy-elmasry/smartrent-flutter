# Wallet Screen Refactoring - Visual Architecture

## 📐 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        WalletScreen                         │
│                  (ResponsiveLayout Router)                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Mobile < 600px    │    Tablet ≥ 600px              │   │
│  │ (WalletMobileScreen) (WalletTabletScreen)           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
          │                                    │
          ▼                                    ▼
    ┌──────────────┐                  ┌──────────────┐
    │   Mobile     │                  │   Tablet     │
    │   Layout     │                  │   Layout     │
    │              │                  │              │
    │ CustomScroll │                  │ CustomScroll │
    │   View       │                  │   View       │
    └──────────────┘                  └──────────────┘
          │                                    │
          └────────────────┬───────────────────┘
                           ▼
            ┌──────────────────────────┐
            │    Shared Widgets        │
            └──────────────────────────┘
                    │ │ │ │ │ │
    ┌───────────────┼─┼─┼─┼─┼───────────────┐
    ▼       ▼       ▼ ▼ ▼ ▼ ▼               ▼
  Balance Transaction Transaction Transactions Top-Up Top-Up
  Card    Item      List        Header       Button Dialog
```

## 🎨 Component Hierarchy

```
WalletScreen
├── ResponsiveLayout
│   ├── WalletMobileScreen
│   │   └── Scaffold
│   │       └── CustomScrollView
│   │           ├── SliverToBoxAdapter → BalanceCardWidget
│   │           ├── SliverToBoxAdapter → TopUpButtonWidget
│   │           ├── SliverToBoxAdapter → TransactionsHeaderWidget
│   │           └── TransactionsListWidget
│   │               └── SliverList
│   │                   └── TransactionItemWidget (multiple)
│   │
│   └── WalletTabletScreen
│       └── Scaffold
│           └── CustomScrollView
│               ├── SliverToBoxAdapter → Balance Section
│               │   └── BalanceCardWidget
│               ├── SliverToBoxAdapter → TopUpButtonWidget
│               ├── SliverToBoxAdapter → TransactionsHeaderWidget
│               └── TransactionsListWidget
│                   └── SliverList
│                       └── TransactionItemWidget (multiple)
│
├── BalanceCardWidget
│   └── Manages own state for:
│       ├── Loading card
│       ├── Empty card
│       ├── Balance card (with gradient)
│       ├── Currency header
│       └── Balance info
│
├── TopUpButtonWidget
│   └── Triggers dialog on tap
│
├── TopUpDialogWidget
│   └── Form with:
│       ├── Amount TextField
│       ├── Currency Dropdown
│       ├── Test Top-up Checkbox (debug)
│       └── Confirm/Cancel buttons
│
├── TransactionsHeaderWidget
│   └── Section title + refresh spinner
│
├── TransactionsListWidget
│   └── State management for:
│       ├── Loading state
│       ├── Error state
│       ├── Empty state
│       ├── Success state with SliverList
│       └── Pagination (load more)
│
└── TransactionItemWidget
    └── Individual card with:
        ├── Icon (type-specific)
        ├── Title (localized)
        ├── Description
        ├── Timestamp
        ├── Amount (with +/-)
        └── Status badge
```

## 🔄 Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    WalletController                         │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ State Variables:                                      │  │
│  │ - balances: Rx<List<WalletBalance>>                  │  │
│  │ - transactions: RxList<WalletTransaction>            │  │
│  │ - isLoadingBalance, isLoadingTransactions            │  │
│  │ - error, hasMore                                     │  │
│  │ - optimisticBalanceChanges: RxMap                    │  │
│  └───────────────────────────────────────────────────────┘  │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
   ┌─────────┐   ┌─────────┐   ┌──────────┐
   │ Balance │   │   Trans │   │ Optimist │
   │  Card   │   │ actions │   │   Updates│
   └─────────┘   └─────────┘   └──────────┘
        │              │             │
        └──────────────┼─────────────┘
                       │
                       ▼
              ┌─────────────────┐
              │ API/Backend     │
              └─────────────────┘
```

## 📱 Responsive Behavior

### Mobile (< 600px)
```
╔════════════════════════════╗
║          AppBar            │
║      (My Wallet)           │
╠════════════════════════════╣
║                            │
║   ┌──────────────────┐    │
║   │  Balance Card    │    │
║   │  (full width)    │    │
║   └──────────────────┘    │
║                            │
║   ┌──────────────────┐    │
║   │ Top-up Button    │    │
║   │ (full width)     │    │
║   └──────────────────┘    │
║                            │
║  Recent Transactions       │
║  ┌──────────────────┐    │
║  │ Trans Item 1     │    │
║  │ ✓ Completed      │    │
║  └──────────────────┘    │
║  ┌──────────────────┐    │
║  │ Trans Item 2     │    │
║  │ ⏳ Pending       │    │
║  └──────────────────┘    │
║  ┌──────────────────┐    │
║  │ Trans Item 3     │    │
║  │ ✗ Failed         │    │
║  └──────────────────┘    │
║                            │
╚════════════════════════════╝
```

### Tablet (≥ 600px)
```
╔═════════════════════════════════════════════════════════════════╗
║                     AppBar (My Wallet)                          │
╠═════════════════════════════════════════════════════════════════╣
║                                                                   ║
║  ┌──────────────────────────────────────────────────────────┐  ║
║  │  Wallet Balance                                          │  ║
║  │  ┌────────────────────────────────────────────────────┐ │  ║
║  │  │     Balance Card (centered, wider)                 │ │  ║
║  │  │     • Available Balance: XXXX.XX SAR              │ │  ║
║  │  └────────────────────────────────────────────────────┘ │  ║
║  └──────────────────────────────────────────────────────────┘  ║
║                                                                   ║
║  ┌──────────────────────────────────────────────────────────┐  ║
║  │  [ Top-up Wallet Button - Expanded ]                    │  ║
║  └──────────────────────────────────────────────────────────┘  ║
║                                                                   ║
║  ┌──────────────────────────────────────────────────────────┐  ║
║  │  Recent Transactions          [⟳]                       │  ║
║  ├──────────────────────────────────────────────────────────┤  ║
║  │ ┌──────────────────────────────────────────────────────┐ │  ║
║  │ │ Icon  Trans Type    Date/Time        +Amount  Status │ │  ║
║  │ │  ➕  Top Up       Nov 21, 10:30      +500 SAR ✓     │ │  ║
║  │ └──────────────────────────────────────────────────────┘ │  ║
║  │ ┌──────────────────────────────────────────────────────┐ │  ║
║  │ │  ➖  Payment      Nov 20, 15:45       -250 SAR ✓     │ │  ║
║  │ └──────────────────────────────────────────────────────┘ │  ║
║  │ ┌──────────────────────────────────────────────────────┐ │  ║
║  │ │  🔄  Refund       Nov 19, 08:20      +100 SAR ⏳     │ │  ║
║  │ └──────────────────────────────────────────────────────┘ │  ║
║  └──────────────────────────────────────────────────────────┘  ║
║                                                                   ║
╚═════════════════════════════════════════════════════════════════╝
```

## 🎯 Widget Interaction Flow

```
User Interaction
       │
       ├─ Pull to Refresh
       │  └─ controller.refresh()
       │     └─ Reload balance & transactions
       │
       ├─ Tap Top-up Button
       │  └─ showDialog(TopUpDialogWidget)
       │     ├─ Enter amount
       │     ├─ Select currency
       │     └─ Tap Continue
       │        └─ initiateTopUp() or initiateTopUpTest()
       │           └─ Navigate to PayTabs or update locally
       │              └─ startPollingTransaction()
       │
       ├─ Scroll to bottom
       │  └─ Auto load more transactions
       │     └─ controller.fetchTransactions(loadMore: true)
       │        └─ Update hasMore flag
       │
       └─ Error state
          └─ Tap Retry
             └─ controller.refresh()
```

## 💾 State Management Flow

```
Controller State Changes
       │
       ├─ Rx<List<WalletBalance>> balances
       │  └─ BalanceCardWidget observes with Obx
       │     └─ Rebuilds when balance changes
       │
       ├─ RxList<WalletTransaction> transactions
       │  └─ TransactionsListWidget observes
       │     └─ TransactionItemWidget rebuilt per item
       │
       ├─ RxBool isLoadingBalance, isLoadingTransactions
       │  └─ Various widgets show/hide loaders
       │
       ├─ RxString error
       │  └─ TransactionsListWidget shows error state
       │
       ├─ RxBool hasMore
       │  └─ Shows "load more" indicator
       │
       └─ RxMap<String, double> optimisticBalanceChanges
          └─ BalanceCardWidget shows pending indicator
```

## 🎨 Styling & Theming

```
Colors:
├─ Primary: Theme.of(context).primaryColor
│  └─ Used for balance card gradient
├─ White: Colors.white
│  └─ Text on colored backgrounds
├─ Green: Colors.green
│  └─ Credit amounts & completed status
├─ Red: Colors.red
│  └─ Debit amounts & failed status
├─ Blue: Colors.blue
│  └─ Refund transactions
├─ Orange: Colors.orange
│  └─ Pending status
├─ Grey: Colors.grey
│  └─ Empty states & cancelled status
└─ Amber: Colors.amber
   └─ Processing indicator

Typography:
├─ 28.sp: Balance amount (large)
├─ 20.sp: Tablet section titles
├─ 18.sp: Screen titles
├─ 16.sp: Currency label
├─ 14.sp: Transaction titles & amounts
├─ 12.sp: Balance label & descriptions
├─ 11.sp: Timestamps
└─ 9.sp:  Status badges

Spacing (responsive):
├─ 16.w: Horizontal padding (most elements)
├─ 8.h:  Small vertical spacing
├─ 16.h: Standard vertical spacing
└─ Larger on tablet screen for readability
```

## 🔐 Error Handling States

```
TransactionsListWidget
├─ isLoadingTransactions ✓ empty list
│  └─ Shows loading spinner with message
├─ error ✓ empty list
│  └─ Shows error icon, message, retry button
├─ transactions ✓ empty
│  └─ Shows empty state icon and message
└─ transactions ✓ has data
   └─ Shows SliverList with items
      └─ At bottom: hasMore ✓ → shows load spinner
                    hasMore ✗ → shows nothing

BalanceCardWidget
├─ isLoadingBalance ✓ empty balances
│  └─ Shows loading card
├─ balances ✓ empty
│  └─ Shows empty state card
└─ balances ✓ has data
   └─ Shows balance card with gradient
      └─ optimisticChange ✓ → shows pending badge
```

---

**Visual Architecture Complete**
Date: November 21, 2025
