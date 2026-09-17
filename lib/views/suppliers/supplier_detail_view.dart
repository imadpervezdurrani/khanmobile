import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/supplier_model.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/status_badge.dart';
import 'record_payment_dialog.dart';

class SupplierDetailView extends StatelessWidget {
  final SupplierModel supplier;

  const SupplierDetailView({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Consumer<SupplierProvider>(
      builder: (context, provider, child) {
        // Find latest version of this supplier from provider
        final currentSupplier = provider.allSuppliers.firstWhere(
          (s) => s.id == supplier.id,
          orElse: () => supplier,
        );

        final payments = provider.getPaymentsForSupplier(currentSupplier.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(currentSupplier.companyName),
            actions: [
              IconButton(
                icon: const Icon(Icons.payment),
                tooltip: "Pay Supplier",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        RecordPaymentDialog(supplier: currentSupplier),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) =>
                    RecordPaymentDialog(supplier: currentSupplier),
              );
            },
            backgroundColor: const Color(0xFF10B981),
            icon: const Icon(Icons.payment),
            label: const Text("Pay Supplier"),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C2541) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2A395E)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentSupplier.companyName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Contact: ${currentSupplier.name}",
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge.forPayable(currentSupplier.balanceDue),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 16, color: Color(0xFF0284C7)),
                          const SizedBox(width: 8),
                          Text(currentSupplier.phone,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      if (currentSupplier.address != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 16, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                currentSupplier.address!,
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Financial Ledger Summary Box
                Row(
                  children: [
                    Expanded(
                      child: _balanceCard(
                        "Total Purchased",
                        currencyFormat.format(currentSupplier.totalBilled),
                        const Color(0xFF0284C7),
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _balanceCard(
                        "Total Paid",
                        currencyFormat.format(currentSupplier.totalPaid),
                        const Color(0xFF10B981),
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _balanceCard(
                        "Payable Due",
                        currencyFormat.format(currentSupplier.balanceDue),
                        currentSupplier.balanceDue > 0
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                        isDark,
                        isAlert: currentSupplier.balanceDue > 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Payments History Section
                Text(
                  "Payment History (${payments.length})",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                if (payments.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C2541) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2A395E)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "No payment records for this supplier yet",
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: payments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final p = payments[index];
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.check_circle_outline,
                                  color: Color(0xFF10B981), size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Paid via ${p.paymentMethod}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    DateFormat('dd MMM yyyy, hh:mm a')
                                        .format(p.date),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  if (p.referenceNumber != null &&
                                      p.referenceNumber!.isNotEmpty)
                                    Text(
                                      "Ref: ${p.referenceNumber}",
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        color: Color(0xFF0284C7),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              currencyFormat.format(p.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF10B981),
                              ),
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
      },
    );
  }

  Widget _balanceCard(
      String label, String value, Color color, bool isDark,
      {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAlert
              ? const Color(0xFFEF4444)
              : (isDark ? const Color(0xFF2A395E) : const Color(0xFFE2E8F0)),
          width: isAlert ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
