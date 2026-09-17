import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/reports_provider.dart';
import '../../providers/sales_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/financial_metric_card.dart';

class ProfitLossView extends StatelessWidget {
  const ProfitLossView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    final reportsProvider = Provider.of<ReportsProvider>(context);
    final salesProvider = Provider.of<SalesProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final supplierProvider = Provider.of<SupplierProvider>(context);

    final report = reportsProvider.generateReport(
      salesProvider: salesProvider,
      expenseProvider: expenseProvider,
      inventoryProvider: inventoryProvider,
      supplierProvider: supplierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profit & Loss Report"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Filter Selector Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _periodChip(context, reportsProvider, ReportPeriod.today, "Today"),
                  const SizedBox(width: 8),
                  _periodChip(context, reportsProvider, ReportPeriod.thisWeek, "This Week"),
                  const SizedBox(width: 8),
                  _periodChip(context, reportsProvider, ReportPeriod.thisMonth, "This Month"),
                  const SizedBox(width: 8),
                  _periodChip(context, reportsProvider, ReportPeriod.thisYear, "This Year"),
                  const SizedBox(width: 8),
                  _periodChip(context, reportsProvider, ReportPeriod.allTime, "All Time"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Net Profit / Loss Highlight Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: report.isProfitable
                    ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                    : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEF2F2)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: report.isProfitable
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (report.isProfitable
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))
                        .withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            report.isProfitable
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: report.isProfitable
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            report.isProfitable
                                ? "NET PROFIT (${reportsProvider.periodDisplayName})"
                                : "NET LOSS (${reportsProvider.periodDisplayName})",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: report.isProfitable
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (report.isProfitable
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444))
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${report.netProfitPercentage.toStringAsFixed(1)}% Margin",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: report.isProfitable
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      currencyFormat.format(report.netProfit),
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: report.isProfitable
                            ? (isDark ? Colors.white : const Color(0xFF065F46))
                            : (isDark ? Colors.white : const Color(0xFF991B1B)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Gross Profit: ${currencyFormat.format(report.grossProfit)}  •  Expenses: -${currencyFormat.format(report.totalExpenses)}",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // P&L Breakdown Cards Grid
            Text(
              "Financial Statement Breakdown",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: FinancialMetricCard(
                    title: "Sales Revenue",
                    amount: currencyFormat.format(report.totalRevenue),
                    percentage: "${report.totalUnitsSold} Units",
                    icon: Icons.point_of_sale,
                    themeColor: const Color(0xFF0284C7),
                    isPositive: true,
                    caption: "Gross Device Sales",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FinancialMetricCard(
                    title: "Cost of Goods (COGS)",
                    amount: currencyFormat.format(report.totalCostOfGoodsSold),
                    icon: Icons.inventory_2_outlined,
                    themeColor: const Color(0xFF64748B),
                    isPositive: false,
                    caption: "Purchase cost of sold phones",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: FinancialMetricCard(
                    title: "Gross Profit",
                    amount: currencyFormat.format(report.grossProfit),
                    percentage:
                        "${report.grossMarginPercentage.toStringAsFixed(1)}%",
                    icon: Icons.monetization_on_outlined,
                    themeColor: const Color(0xFF10B981),
                    isPositive: report.grossProfit >= 0,
                    caption: "Sales - Phone Costs",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FinancialMetricCard(
                    title: "Shop Expenses",
                    amount: currencyFormat.format(report.totalExpenses),
                    icon: Icons.money_off,
                    themeColor: const Color(0xFFEF4444),
                    isPositive: false,
                    caption: "Rent, bills & salaries",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Profit Equation Strip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2541) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A395E) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "P&L Accounting Formula",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  _formulaRow("Gross Revenue (From Phones)",
                      currencyFormat.format(report.totalRevenue), false),
                  _formulaRow("Less: Purchase Cost of Sold Phones",
                      "- ${currencyFormat.format(report.totalCostOfGoodsSold)}", false),
                  const Divider(height: 16),
                  _formulaRow(
                    "= Gross Profit",
                    currencyFormat.format(report.grossProfit),
                    true,
                    color: const Color(0xFF10B981),
                  ),
                  _formulaRow("Less: Total Operational Expenses",
                      "- ${currencyFormat.format(report.totalExpenses)}", false),
                  const Divider(height: 16),
                  _formulaRow(
                    "= Net Profit / Loss",
                    currencyFormat.format(report.netProfit),
                    true,
                    color: report.isProfitable
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Balance Sheet & Khata Payables Overview
            Text(
              "Shop Assets & Supplier Payables (Balance Sheet)",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2541) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A395E) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  _assetRow(
                    "Current Stock Valuation (Cost)",
                    currencyFormat.format(report.inventoryCostInStock),
                    Icons.storefront,
                    const Color(0xFF0284C7),
                    isDark,
                  ),
                  const Divider(height: 20),
                  _assetRow(
                    "Expected Retail Value of Stock",
                    currencyFormat.format(report.inventoryRetailValue),
                    Icons.sell_outlined,
                    const Color(0xFF6366F1),
                    isDark,
                  ),
                  const Divider(height: 20),
                  _assetRow(
                    "Total Supplier Payables Due (Khata)",
                    currencyFormat.format(report.totalSupplierPayable),
                    Icons.warning_amber_rounded,
                    const Color(0xFFEF4444),
                    isDark,
                  ),
                  const Divider(height: 20),
                  _assetRow(
                    "Net Inventory Equity (Stock Cost - Payables)",
                    currencyFormat.format(report.inventoryCostInStock -
                        report.totalSupplierPayable),
                    Icons.account_balance_wallet,
                    const Color(0xFF10B981),
                    isDark,
                    isHighlight: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodChip(BuildContext context, ReportsProvider provider,
      ReportPeriod period, String label) {
    final isSelected = provider.selectedPeriod == period;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => provider.setPeriod(period),
    );
  }

  Widget _formulaRow(String label, String value, bool isBold, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _assetRow(String label, String value, IconData icon, Color color,
      bool isDark,
      {bool isHighlight = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isHighlight ? 16 : 14,
            color: color,
          ),
        ),
      ],
    );
  }
}
