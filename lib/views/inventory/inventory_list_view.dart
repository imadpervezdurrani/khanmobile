import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/device_model.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/status_badge.dart';
import 'add_edit_device_view.dart';
import 'device_detail_dialog.dart';
import '../sales/new_sale_dialog.dart';

class InventoryListView extends StatelessWidget {
  const InventoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        final devices = provider.filteredDevices;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Mobile Stock Inventory"),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: "Refresh Stock",
                onPressed: () {},
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditDeviceView()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Phone"),
          ),
          body: Column(
            children: [
              // Stock Valuation Banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2541) : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A395E) : const Color(0xFFBAE6FD),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Stock in Hand",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF0369A1),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${provider.inStockCount} Units",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Stock Valuation (Cost)",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF0369A1),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormat.format(provider.totalStockCostValue),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ],
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
                    hintText: "Search by Model, Brand, or 15-digit IMEI...",
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
              const SizedBox(height: 10),

              // Status Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _filterChip(context, "All (${provider.allDevices.length})",
                        provider.selectedStatus == 'All', () => provider.setSelectedStatus('All')),
                    const SizedBox(width: 8),
                    _filterChip(context, "In Stock (${provider.inStockCount})",
                        provider.selectedStatus == 'in_stock', () => provider.setSelectedStatus('in_stock')),
                    const SizedBox(width: 8),
                    _filterChip(context, "Sold (${provider.soldCount})",
                        provider.selectedStatus == 'sold', () => provider.setSelectedStatus('sold')),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Brand Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: provider.availableBrands.map((brand) {
                    final isSelected = provider.selectedBrand == brand;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(brand),
                        selected: isSelected,
                        onSelected: (_) => provider.setSelectedBrand(brand),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),

              // Device List
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : devices.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone_android,
                                    size: 54, color: theme.disabledColor),
                                const SizedBox(height: 12),
                                Text(
                                  "No mobile devices found",
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Try a different search query or add a device",
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                            itemCount: devices.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final device = devices[index];
                              return _buildDeviceCard(
                                  context, device, currencyFormat, isDark);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(BuildContext context, String label, bool isSelected,
      VoidCallback onSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
    );
  }

  Widget _buildDeviceCard(BuildContext context, DeviceModel device,
      NumberFormat currencyFormat, bool isDark) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => DeviceDetailDialog(
            device: device,
            onSell: () {
              showDialog(
                context: context,
                builder: (_) => NewSaleDialog(preselectedDevice: device),
              );
            },
          ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.smartphone,
                      color: Color(0xFF0284C7), size: 24),
                ),
                const SizedBox(width: 12),

                // Specs & Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            device.brand,
                            style: const TextStyle(
                              color: Color(0xFF0284C7),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge.forCondition(device.condition),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        device.model,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${device.storage} • ${device.ram} RAM • ${device.color}",
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                StatusBadge.forStock(device.status),
              ],
            ),
            const SizedBox(height: 10),

            // IMEI Barcode Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF243054)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code, size: 14, color: Color(0xFF0284C7)),
                  const SizedBox(width: 6),
                  Text(
                    "IMEI: ${device.imei1}",
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (device.supplierName != null)
                    Text(
                      device.supplierName!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Pricing & Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cost: ${currencyFormat.format(device.purchasePrice)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      currencyFormat.format(device.sellingPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
                if (device.isInStock)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => NewSaleDialog(preselectedDevice: device),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_checkout, size: 16),
                    label: const Text("Sell Device"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
