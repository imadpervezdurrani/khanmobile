import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/sales_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/stat_card.dart';
import '../inventory/add_edit_device_view.dart';
import '../sales/new_sale_dialog.dart';
import '../expenses/add_expense_dialog.dart';
import '../suppliers/record_payment_dialog.dart';

class DashboardView extends StatelessWidget {
  final Function(int) onNavigateTab;

  const DashboardView({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final salesProvider = Provider.of<SalesProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final supplierProvider = Provider.of<SupplierProvider>(context);
    final reportsProvider = Provider.of<ReportsProvider>(context);

    // Compute Net Profit for This Month
    final report = reportsProvider.generateReport(
      salesProvider: salesProvider,
      expenseProvider: expenseProvider,
      inventoryProvider: inventoryProvider,
      supplierProvider: supplierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.phone_android,
                  color: Color(0xFF0284C7), size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Mobile Zone Manager",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  "Shop Inventory & POS System",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Stat Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.25,
              children: [
                StatCard(
                  title: "Stock in Hand",
                  value: "${inventoryProvider.inStockCount} Units",
                  icon: Icons.inventory_2_outlined,
                  iconColor: const Color(0xFF0284C7),
                  subtitle: currencyFormat.format(inventoryProvider.totalStockCostValue),
                  onTap: () => onNavigateTab(1), // Inventory tab
                ),
                StatCard(
                  title: "Today's Sales",
                  value: currencyFormat.format(salesProvider.todayRevenue),
                  icon: Icons.point_of_sale,
                  iconColor: const Color(0xFF10B981),
                  subtitle: "${salesProvider.todaySalesCount} Phones Sold",
                  onTap: () => onNavigateTab(2), // Sales tab
                ),
                StatCard(
                  title: "Net Profit (Month)",
                  value: currencyFormat.format(report.netProfit),
                  icon: Icons.trending_up,
                  iconColor: report.isProfitable
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  accentColor: report.isProfitable
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  subtitle: "${report.netProfitPercentage.toStringAsFixed(1)}% Net Margin",
                  onTap: () => onNavigateTab(5), // Reports tab
                ),
                StatCard(
                  title: "Supplier Payables",
                  value: currencyFormat.format(supplierProvider.totalAccountsPayable),
                  icon: Icons.business,
                  iconColor: const Color(0xFFEF4444),
                  accentColor: const Color(0xFFEF4444),
                  subtitle: "${supplierProvider.suppliersWithPayables.length} Dues Pending",
                  onTap: () => onNavigateTab(4), // Suppliers tab
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Quick Actions Bar
            Text(
              "Quick Operations",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _quickActionButton(
                    context,
                    label: "Add Phone",
                    icon: Icons.add_shopping_cart,
                    color: const Color(0xFF0284C7),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddEditDeviceView()),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _quickActionButton(
                    context,
                    label: "POS New Sale",
                    icon: Icons.point_of_sale,
                    color: const Color(0xFF10B981),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const NewSaleDialog(),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _quickActionButton(
                    context,
                    label: "Add Expense",
                    icon: Icons.money_off,
                    color: const Color(0xFFEF4444),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AddExpenseDialog(),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _quickActionButton(
                    context,
                    label: "Pay Supplier",
                    icon: Icons.payment,
                    color: const Color(0xFF6366F1),
                    onTap: () {
                      final firstWithDue = supplierProvider.allSuppliers
                          .firstWhere((s) => s.hasOutstandingPayable,
                              orElse: () => supplierProvider.allSuppliers.first);
                      showDialog(
                        context: context,
                        builder: (_) =>
                            RecordPaymentDialog(supplier: firstWithDue),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Sales Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Sales Invoices",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateTab(2),
                  child: const Text("View All"),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (salesProvider.allSales.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2541) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A395E) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "No sales recorded yet",
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: salesProvider.allSales.take(3).length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final sale = salesProvider.allSales[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C2541) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2A395E)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.phone_android,
                                  color: Color(0xFF10B981), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${sale.deviceBrand} ${sale.deviceModel}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "${sale.customerName} • ${DateFormat('dd MMM').format(sale.saleDate)}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(sale.finalPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "+${currencyFormat.format(sale.profit)} profit",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton(BuildContext context,
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
