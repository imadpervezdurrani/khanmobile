import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/supplier_model.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/status_badge.dart';
import 'add_supplier_dialog.dart';
import 'record_payment_dialog.dart';
import 'supplier_detail_view.dart';

class SuppliersView extends StatelessWidget {
  const SuppliersView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Consumer<SupplierProvider>(
      builder: (context, provider, child) {
        final suppliers = provider.filteredSuppliers;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Suppliers & Accounts Payable (Khata)"),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddSupplierDialog(),
              );
            },
            backgroundColor: const Color(0xFF6366F1),
            icon: const Icon(Icons.add_business),
            label: const Text("Add Supplier"),
          ),
          body: Column(
            children: [
              // Total Accounts Payable Banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2541) : const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A395E) : const Color(0xFFFFCDD2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _kpi(
                      "Total Accounts Payable",
                      currencyFormat.format(provider.totalAccountsPayable),
                      const Color(0xFFEF4444),
                      isDark,
                      isBold: true,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: isDark ? const Color(0xFF2A395E) : const Color(0xFFD1D5DB),
                    ),
                    _kpi(
                      "Total Stock Billed",
                      currencyFormat.format(provider.totalBilledFromSuppliers),
                      const Color(0xFF0284C7),
                      isDark,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: isDark ? const Color(0xFF2A395E) : const Color(0xFFD1D5DB),
                    ),
                    _kpi(
                      "Total Paid Out",
                      currencyFormat.format(provider.totalPaidToSuppliers),
                      const Color(0xFF10B981),
                      isDark,
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: provider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: "Search suppliers by company, name, or phone...",
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: provider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => provider.setSearchQuery(''),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Supplier List
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : suppliers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.business_outlined,
                                    size: 54, color: theme.disabledColor),
                                const SizedBox(height: 12),
                                Text(
                                  "No suppliers found",
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Add your phone distributors and suppliers to track Khata",
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            itemCount: suppliers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final supplier = suppliers[index];
                              return _buildSupplierCard(
                                  context, supplier, currencyFormat, isDark);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _kpi(
      String label, String value, Color color, bool isDark,
      {bool isBold = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isBold ? 16 : 14,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierCard(BuildContext context, SupplierModel supplier,
      NumberFormat currencyFormat, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SupplierDetailView(supplier: supplier),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2541) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: supplier.hasOutstandingPayable
                ? const Color(0xFFEF4444).withOpacity(0.4)
                : (isDark ? const Color(0xFF2A395E) : const Color(0xFFE2E8F0)),
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.business,
                          color: Color(0xFF6366F1), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.companyName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "${supplier.name} • ${supplier.phone}",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                StatusBadge.forPayable(supplier.balanceDue),
              ],
            ),
            const SizedBox(height: 12),

            // Financial row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Purchased: ${currencyFormat.format(supplier.totalBilled)}",
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      "Paid: ${currencyFormat.format(supplier.totalPaid)}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Payable Due",
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        ),
                        Text(
                          currencyFormat.format(supplier.balanceDue),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: supplier.balanceDue > 0
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: const Size(0, 34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) =>
                              RecordPaymentDialog(supplier: supplier),
                        );
                      },
                      child: const Text("Pay", style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
