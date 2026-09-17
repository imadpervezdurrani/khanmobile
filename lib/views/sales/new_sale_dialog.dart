import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/device_model.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/sales_provider.dart';
import '../../widgets/custom_text_field.dart';
import 'sale_receipt_dialog.dart';

class NewSaleDialog extends StatefulWidget {
  final DeviceModel? preselectedDevice;

  const NewSaleDialog({super.key, this.preselectedDevice});

  @override
  State<NewSaleDialog> createState() => _NewSaleDialogState();
}

class _NewSaleDialogState extends State<NewSaleDialog> {
  final _formKey = GlobalKey<FormState>();

  DeviceModel? _selectedDevice;
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  String _paymentMethod = 'Cash';
  bool _isProcessing = false;

  final List<String> _paymentMethods = [
    'Cash',
    'Bank Transfer',
    'Easypaisa / JazzCash',
    'Credit Card',
    'Customer Khata / Credit',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preselectedDevice != null) {
      _selectedDevice = widget.preselectedDevice;
      _sellingPriceController.text =
          widget.preselectedDevice!.sellingPrice.toStringAsFixed(0);
    }
  }

  double get _sellingPrice =>
      double.tryParse(_sellingPriceController.text) ?? 0.0;
  double get _discount => double.tryParse(_discountController.text) ?? 0.0;
  double get _finalBill => _sellingPrice - _discount;
  double get _costPrice => _selectedDevice?.purchasePrice ?? 0.0;
  double get _profit => _finalBill - _costPrice;

  Future<void> _completeSale() async {
    if (_selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a device to sell")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final sale = await Provider.of<SalesProvider>(context, listen: false)
          .recordSale(
        device: _selectedDevice!,
        sellingPrice: _sellingPrice,
        discount: _discount,
        customerName: _customerNameController.text.trim().isNotEmpty
            ? _customerNameController.text.trim()
            : "Walk-in Customer",
        customerPhone: _customerPhoneController.text.trim(),
        paymentMethod: _paymentMethod,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context); // Close sale dialog
        // Show receipt
        showDialog(
          context: context,
          builder: (_) => SaleReceiptDialog(sale: sale),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sale processing failed: $e"),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    final inStockDevices =
        Provider.of<InventoryProvider>(context).inStockDevices;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.point_of_sale,
                              color: Color(0xFF10B981), size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "New POS Mobile Sale",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Device Selection
                Text(
                  "Select Handset to Sell",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF243054) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2A395E) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DeviceModel?>(
                      value: _selectedDevice,
                      isExpanded: true,
                      hint: const Text("Choose from in-stock devices..."),
                      items: inStockDevices.map((dev) {
                        return DropdownMenuItem(
                          value: dev,
                          child: Text(
                            "${dev.brand} ${dev.model} (${dev.storage}) - IMEI: ${dev.imei1}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (device) {
                        setState(() {
                          _selectedDevice = device;
                          if (device != null) {
                            _sellingPriceController.text =
                                device.sellingPrice.toStringAsFixed(0);
                          }
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Customer Information
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _customerNameController,
                        label: "Customer Name",
                        hint: "e.g. Ali Raza",
                        prefixIcon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _customerPhoneController,
                        label: "Customer Phone",
                        hint: "0300-1234567",
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pricing, Discount & Payment Method
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _sellingPriceController,
                        label: "Sale Price (Rs.)",
                        prefixIcon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        validator: (val) =>
                            val == null || double.tryParse(val) == null
                                ? "Invalid"
                                : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _discountController,
                        label: "Discount (Rs.)",
                        prefixIcon: Icons.discount_outlined,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Payment Method
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payment Mode",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF243054)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2A395E)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _paymentMethod,
                          isExpanded: true,
                          items: _paymentMethods
                              .map((m) =>
                                  DropdownMenuItem(value: m, child: Text(m)))
                              .toList(),
                          onChanged: (m) {
                            if (m != null) setState(() => _paymentMethod = m);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Live Financial Computation Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2A395E) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Final Payable Amount:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            currencyFormat.format(_finalBill),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Estimated Profit:",
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                          Text(
                            currencyFormat.format(_profit),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _profit >= 0
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Confirm Sale Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isProcessing ? null : _completeSale,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(
                      _isProcessing ? "Processing Sale..." : "Complete & Generate Receipt",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
