# 🏪 Saju Store - Confectionary & Grocery Sales Management App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Proprietary-green)](#)

A high-performance, offline-first Flutter application tailored for sweet shops, grocery stores, and confectionaries (মুদি ও মিষ্টির দোকান). Built with SQLite for robust, long-term offline accounting, daily/monthly analytics, customer credit (বাকি) tracking, and cash sale receipts.

---

## 🌟 Key Features

- **💵 Cash Sales (ক্যাশ সেল):**
  - Record multi-item single-receipt transactions with live subtotal calculation.
  - View full itemized receipts with edit and delete capabilities.
- **📒 Customer Accounts & Credit Ledger (বাকি খাতা):**
  - Manage customer profiles with names and phone numbers.
  - Instant customer search by name or contact number.
  - Record credit purchases and payments (টাকা জমা) with automated balance deduction.
- **📊 Business Dashboard & Analytics:**
  - Real-time today's summary: Total sales, cash received, and credit outstanding.
  - Month-over-month browsing with dynamic historical calculations.
  - Multi-calendar header display: **Bangla (বাংলা সন)**, **Gregorian (ইংরেজি)**, and **Hijri (হিজরি সন)** dates.
- **🛡️ Data Integrity & Atomicity:**
  - Database operations use atomic SQLite transactions (`db.transaction`) to prevent partial or corrupted saves.
  - Fast indexed queries utilizing SQL aggregations (`GROUP BY`, `SUM`) designed for 10-15+ years of operational records.

---

## 🏗️ Project Architecture

The codebase follows a clean, feature-first modular architecture for maintainability and scalability:

```text
lib/
├── core/
│   ├── constants/              # Reusable app colors, strings, and styling tokens
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_styles.dart
│   ├── database/               # SQLite helper with atomic transactions & CRUD operations
│   │   └── database_helper.dart
│   ├── theme/                  # Material 3 custom theme configuration
│   │   └── app_theme.dart
│   └── utils/                  # Multi-calendar date helpers (Bangla, English, Hijri)
│       └── date_helper.dart
├── models/                     # Data models with immutability and serialization
│   ├── account.dart
│   ├── sale.dart
│   └── sale_transaction.dart
├── screens/
│   ├── home/                   # Main dashboard, summary cards & calendar header
│   │   ├── home_screen.dart
│   │   └── widgets/
│   │       ├── date_header_card.dart
│   │       └── summary_card.dart
│   ├── cash_sales/             # Cash sales ledger and multi-item receipt creation
│   │   ├── cash_sales_screen.dart
│   │   └── add_cash_sale_screen.dart
│   ├── accounts/               # Customer account list, ledger details, and credit sale entry
│   │   ├── account_list_screen.dart
│   │   ├── account_detail_screen.dart
│   │   └── add_account_sale_screen.dart
│   └── common/                 # Reusable UI components & dialogs
│       └── widgets/
│           ├── confirm_dialog.dart
│           ├── product_entry_item.dart
│           └── transaction_detail_dialog.dart
└── main.dart                   # Application entry point
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.19 or higher)
- Android Studio / VS Code with Flutter extension
- Android device or emulator

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/osman4466/sajustore.git
   cd sajustore
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

---

## 🗃️ Database Schema

| Table | Columns | Description |
| :--- | :--- | :--- |
| **accounts** | `id`, `name`, `phone` | Stores customer profile details. |
| **transactions** | `id`, `type`, `accountId`, `totalAmount`, `date`, `sortableDate` | Stores single transactions (`cash`, `account`, or `payment`). |
| **sales** | `id`, `transactionId`, `productName`, `amount` | Itemized line-items linked to a parent transaction. |

---

## 📝 Documentation
For additional project specifications and roadmap notes, see [`docs/PROJECT_NOTES.md`](docs/PROJECT_NOTES.md).
