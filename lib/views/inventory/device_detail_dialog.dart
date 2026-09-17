import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/device_model.dart';
import '../../widgets/status_badge.dart';

class DeviceDetailDialog extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback onSell;

  const DeviceDetailDialog({
    super.key,
    required this.device,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.brand,
                        style: TextStyle(
                          color: const Color(0xFF0284C7),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        device.model,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge.forStock(device.status),
              ],
            ),
            const Divider(height: 24),

            // Specifications Grid
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _specPill(context, Icons.sd_card_outlined, "Storage", device.storage),
                _specPill(context, Icons.memory_outlined, "RAM", device.ram),
                _specPill(context, Icons.palette_outlined, "Color", device.color),
                _specPill(context, Icons.info_outline, "Condition", device.condition),
              ],
            ),
            const SizedBox(height: 16),

            // IMEI Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A395E) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.qr_code_2, size: 18, color: Color(0xFF0284C7)),
                      const SizedBox(width: 8),
                      Text(
                        "IMEI 1: ${device.imei1}",
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (device.imei2 != null && device.imei2!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.qr_code_2, size: 18, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Text(
                          "IMEI 2: ${device.imei2}",
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pricing & Profitability
            Row(
              children: [
                Expanded(
                  child: _priceBox(
                    context,
                    "Purchase Cost",
                    currencyFormat.format(device.purchasePrice),
                    const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _priceBox(
                    context,
                    "Selling Price",
                    currencyFormat.format(device.sellingPrice),
                    const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _priceBox(
                    context,
                    "Est. Profit",
                    currencyFormat.format(device.potentialProfit),
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (device.supplierName != null) ...[
              Text(
                "Supplier: ${device.supplierName}",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
            ],

            Text(
              "Added on: ${DateFormat('dd MMM yyyy, hh:mm a').format(device.dateAdded)}",
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
                if (device.isInStock) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onSell();
                    },
                    icon: const Icon(Icons.point_of_sale, size: 18),
                    label: const Text("Sell Device"),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _specPill(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A395E)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0284C7)),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _priceBox(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
