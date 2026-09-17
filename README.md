# Mobile Zone Management System (Flutter & Firebase)

A modern, production-grade Flutter application engineered for **Mobile Phone Retail Shops, Distributors, and Inventory Managers**. The system integrates directly with **Google Firebase** (Cloud Firestore & Authentication) and features a dual-mode offline/demo fallback architecture for immediate testing.

---

## 🚀 Key Features

### 1. 📱 Device & Mobile Inventory Management
- **IMEI 1 & IMEI 2 Unique Serial Tracking**: Every mobile handset is indexed and tracked individually.
- **Specifications Tracking**: Brand, Model, Storage (e.g. 128GB, 256GB), RAM, Color, and Condition (`Brand New` vs `Used / Pre-owned`).
- **Profit Margin Preview**: Live calculation of expected profit margin % when inputting Purchase Cost and Selling Price.
- **Supplier Linkage**: Connects purchased handsets to a specific supplier to automatically update accounts payable.
- **Instant Search & Filters**: Search by 15-digit IMEI, Brand, or Model with brand filter chips and stock status tabs (`In Stock` vs `Sold`).

### 2. 🧾 Point of Sale (POS) & Billing
- **Fast IMEI Handset Lookup**: Select an in-stock handset or scan its IMEI.
- **Customer Information**: Record customer name and contact phone number.
- **Live Profit Engine**: Real-time display of net profit on each sale as discounts are applied.
- **Flexible Payment Methods**: Cash, Bank Transfer, Online Wallets (JazzCash/Easypaisa), or Customer Credit.
- **Digital Invoice / Receipt Generator**: Instant receipt with invoice number, date, device specs, IMEI, breakdown of prices, and profit summary.

### 3. 💸 Shop Expense Management
- **Category-Wise Tracking**:
  - Shop Rent
  - Electricity & Bills
  - Staff Salaries & Allowances
  - Daily Tea & Customer Refreshments
  - Shop Maintenance & Repairs
  - Packaging & Supplies
  - Marketing & Other Expenses
- **Monthly & Daily Aggregates**: View today's total expenses, this month's expenses, and category breakdowns.

### 4. 🤝 Supplier & Accounts Payable (Khata / Hisaab)
- **Supplier Directory**: Contact info, company/market address, and phone numbers.
- **Automatic Stock Billing**: Adding handsets from a supplier automatically increases that supplier's total billed amount.
- **Accounts Payable Balance**:
  $$\text{Balance Due} = \text{Total Purchased Billed} - \text{Total Paid Out}$$
- **Color-Coded Badges**: Instant visual alerts for suppliers with pending payables.
- **Record Supplier Payment**: Log cash, bank transfer, or cheque payments to clear outstanding Khata balances.

### 5. 📊 Profit & Loss Financial Reports
- **Complete Accounting Formula**:
  $$\text{Gross Profit} = \text{Total Phone Sales Revenue} - \text{Cost of Goods Sold (COGS)}$$
  $$\text{Net Profit / Loss} = \text{Gross Profit} - \text{Total Operational Expenses}$$
- **Interactive Period Filters**: Filter by `Today`, `This Week`, `This Month`, `This Year`, or `All Time`.
- **Shop Balance Sheet & Valuation**:
  - Current unsold inventory valuation (at cost and expected retail).
  - Total supplier accounts payable due.
  - Net inventory equity.

---

## 🛠️ Project Structure

```
lib/
├── firebase_options.dart         # Multi-platform Firebase credentials
├── main.dart                     # App bootstrapper, MultiProvider, and theme
├── models/
│   ├── device_model.dart         # Mobile specifications and IMEI model
│   ├── sale_model.dart           # Sales invoice and COGS profit model
│   ├── expense_model.dart        # Categorized operational expenses
│   ├── supplier_model.dart       # Supplier profile and Khata balance model
│   ├── supplier_payment_model.dart # Supplier payment transactions
│   └── profit_loss_report.dart  # Financial P&L summary engine
├── providers/
│   ├── inventory_provider.dart   # Device stock state and IMEI search
│   ├── sales_provider.dart       # POS checkout and invoice state
│   ├── expense_provider.dart     # Expense logging and category aggregates
│   ├── supplier_provider.dart    # Accounts payable and payment ledger
│   ├── reports_provider.dart     # Real-time P&L calculation
│   └── theme_provider.dart       # Dark/Light theme toggle
├── services/
│   ├── firebase_service.dart     # Cloud Firestore real-time sync + demo fallback
│   └── auth_service.dart         # Authentication service
├── theme/
│   └── app_theme.dart            # Midnight slate and electric cyan design system
├── views/
│   ├── home_shell.dart           # Responsive navigation shell
│   ├── dashboard/                # Executive KPI summary and quick actions
│   ├── inventory/                # Phone inventory, IMEI search, and Add Device
│   ├── sales/                    # POS terminal, invoices, and digital receipts
│   ├── expenses/                 # Expense manager and category filters
│   ├── suppliers/                # Supplier Khata and record payment
│   ├── reports/                  # Profit & Loss financial statements
│   └── settings/                 # Firebase connection manager & theme toggle
└── widgets/
    ├── custom_text_field.dart    # Theme-styled inputs
    ├── financial_metric_card.dart# P&L financial cards
    ├── stat_card.dart            # Dashboard metric widgets
    └── status_badge.dart         # Dynamic color badges
```

---

## 🌐 Connecting Your Live Firebase Project

The app is built with a dual-mode service architecture:
1. **Interactive Demo / Fallback Mode**: Works out-of-the-box with realistic sample devices, sales, expenses, and supplier data so you can test all screens immediately.
2. **Live Firebase Mode**: To connect your live Firebase project:

### Option A: Using FlutterFire CLI (Recommended)
```bash
# 1. Activate FlutterFire CLI
dart pub global activate flutterfire_cli

# 2. Configure Firebase in this directory
flutterfire configure
```

### Option B: Android Setup
1. Go to [Firebase Console](https://console.firebase.google.com/) and create a project.
2. Add an Android app with package name: `com.mobileshop.mobile_management_system`.
3. Download `google-services.json` and place it inside `android/app/`.
4. Enable **Cloud Firestore** and **Firebase Authentication** in the Firebase Console.

### Cloud Firestore Collections
The app synchronizes with these Firestore collections:
- `devices`: Handset inventory and IMEI records
- `sales`: Sales invoices and profit data
- `expenses`: Operational shop expenses
- `suppliers`: Supplier directory and Khata balances
- `supplier_payments`: Payments made to suppliers

---

## 🏃 Running the Application

Ensure Flutter is installed and run:

```bash
# 1. Get packages
flutter pub get

# 2. Run on connected phone, emulator, or Chrome/Desktop
flutter run
```
