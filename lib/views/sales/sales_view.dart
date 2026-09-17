import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/sale_model.dart';
import '../../providers/sales_provider.dart';
import 'new_sale_dialog.dart';
import 'sale_receipt_dialog.dart';

class SalesView extends StatelessWidget {
  const SalesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        final sales = provider.filteredSales;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Point of Sale & Billing"),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const NewSaleDialog(),
              );
            },
            backgroundColor: const Color(0xFF10B981),
            icon: const Icon(Icons.point_of_sale),
            label: const Text("New Sale"),
          ),
          body: Column(
            children: [
              // Today's Sales Metrics Banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2541) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A395E) : const Color(0xFFA7F3D0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricItem(
                      "Today's Sales",
                      "${provider.todaySalesCount} Phones",
                      const Color(0xFF0284C7),
                      isDark,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: isDark ? const Color(0xFF2A395E) : const Color(0xFFD1D5DB),
                    ),
                    _metricItem(
                      "Today's Revenue",
                      currencyFormat.format(provider.todayRevenue),
                      const Color(0xFF10B981),
                      isDark,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: isDark ? const Color(0xFF2A395E) : const Color(0xFFD1D5DB),
                    ),
                    _metricItem(
                      "Today's Profit",
                      currencyFormat.format(provider.todayProfit),
                      const Color(0xFFF59E0B),
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
                    hintText: "Search by Invoice #, Customer, Phone, or IMEI...",
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

              // Invoices List
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : sales.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 54, color: theme.disabledColor),
                                const SizedBox(height: 12),
                                Text(
                                  "No sales records found",
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Click 'New Sale' to generate your first invoice",
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            itemCount: sales.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final sale = sales[index];
                              return _buildSaleCard(
                                  context, sale, currencyFormat, isDark);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metricItem(
      String label, String value, Color color, bool isDark) {
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
            fontSize: 15,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSaleCard(BuildContext context, SaleModel sale,
      NumberFormat currencyFormat, bool isDark) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => SaleReceiptDialog(sale: sale),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2541) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2A395E) : const Color(0xFFE2E8F0),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sale.invoiceNumber,
                        style: const TextStyle(
                          color: Color(0xFF0284C7),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM, hh:mm a').format(sale.saleDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "+${currencyFormat.format(sale.profit)} Profit",
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Device Name & Customer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${sale.deviceBrand} ${sale.deviceModel} (${sale.deviceStorage})",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Customer: ${sale.customerName} • ${sale.paymentMethod}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(sale.finalPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // IMEI snippet
            Text(
              "IMEI: ${sale.imei1}",
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
