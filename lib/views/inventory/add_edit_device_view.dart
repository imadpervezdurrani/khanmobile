import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/custom_text_field.dart';

class AddEditDeviceView extends StatefulWidget {
  const AddEditDeviceView({super.key});

  @override
  State<AddEditDeviceView> createState() => _AddEditDeviceViewState();
}

class _AddEditDeviceViewState extends State<AddEditDeviceView> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _storageController = TextEditingController(text: '128GB');
  final _ramController = TextEditingController(text: '8GB');
  final _colorController = TextEditingController(text: 'Black');
  final _imei1Controller = TextEditingController();
  final _imei2Controller = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _notesController = TextEditingController();

  String _condition = 'New';
  String? _selectedSupplierId;
  String? _selectedSupplierName;
  bool _isSubmitting = false;

  final List<String> _popularBrands = [
    'Apple',
    'Samsung',
    'Xiaomi',
    'OnePlus',
    'Vivo',
    'Oppo',
    'Realme',
    'Google',
    'Infinix',
    'Tecno',
  ];

  @override
  void initState() {
    super.initState();
    _brandController.text = 'Apple';
  }

  void _generateRandomImei() {
    final random = Random();
    String imei = '35';
    for (int i = 0; i < 13; i++) {
      imei += random.nextInt(10).toString();
    }
    _imei1Controller.text = imei;
  }

  double get _purchasePrice =>
      double.tryParse(_purchasePriceController.text) ?? 0.0;
  double get _sellingPrice =>
      double.tryParse(_sellingPriceController.text) ?? 0.0;
  double get _profit => _sellingPrice - _purchasePrice;
  double get _profitMargin =>
      _purchasePrice > 0 ? (_profit / _purchasePrice) * 100 : 0.0;

  Future<void> _saveDevice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await Provider.of<InventoryProvider>(context, listen: false).addDevice(
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        storage: _storageController.text.trim(),
        ram: _ramController.text.trim(),
        color: _colorController.text.trim(),
        condition: _condition,
        imei1: _imei1Controller.text.trim(),
        imei2: _imei2Controller.text.trim(),
        purchasePrice: _purchasePrice,
        sellingPrice: _sellingPrice,
        supplierId: _selectedSupplierId,
        supplierName: _selectedSupplierName,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mobile device added to stock successfully!"),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error adding device: $e"),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final suppliers = Provider.of<SupplierProvider>(context).allSuppliers;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Mobile Device"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand Quick Select Chips
              Text(
                "Brand",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _popularBrands.map((brand) {
                    final isSelected = _brandController.text == brand;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(brand),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _brandController.text = brand);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Model & Color
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _modelController,
                      label: "Model Name",
                      hint: "e.g. iPhone 15 Pro, Galaxy S24",
                      prefixIcon: Icons.smartphone,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? "Required"
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _colorController,
                      label: "Color",
                      hint: "e.g. Titanium",
                      prefixIcon: Icons.palette_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Storage & RAM & Condition
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _storageController,
                      label: "Storage",
                      hint: "128GB, 256GB",
                      prefixIcon: Icons.sd_card_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _ramController,
                      label: "RAM",
                      hint: "8GB, 12GB",
                      prefixIcon: Icons.memory,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Condition",
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
                              value: _condition,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                    value: 'New', child: Text("Brand New")),
                                DropdownMenuItem(
                                    value: 'Used', child: Text("Used / Pre-owned")),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _condition = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // IMEI 1 & IMEI 2
              CustomTextField(
                controller: _imei1Controller,
                label: "IMEI 1 (Required)",
                hint: "15-digit unique serial/IMEI",
                prefixIcon: Icons.qr_code_scanner,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "IMEI 1 is required for device management";
                  }
                  if (val.trim().length < 10) {
                    return "IMEI is too short";
                  }
                  return null;
                },
                suffix: TextButton.icon(
                  onPressed: _generateRandomImei,
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text("Generate"),
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _imei2Controller,
                label: "IMEI 2 (Optional - Dual SIM)",
                hint: "Optional second IMEI",
                prefixIcon: Icons.qr_code,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Supplier Connection (for Accounts Payable)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Supplier / Purchased From (Khata Link)",
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
                      child: DropdownButton<String?>(
                        value: _selectedSupplierId,
                        isExpanded: true,
                        hint: const Text("Select Supplier (Optional)"),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("None / Direct Purchase"),
                          ),
                          ...suppliers.map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text("${s.companyName} (${s.name})"),
                              )),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedSupplierId = val;
                            if (val != null) {
                              _selectedSupplierName = suppliers
                                  .firstWhere((s) => s.id == val)
                                  .companyName;
                            } else {
                              _selectedSupplierName = null;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Purchase Price & Selling Price
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _purchasePriceController,
                      label: "Purchase Cost (Rs.)",
                      hint: "e.g. 150000",
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      validator: (val) {
                        if (val == null || double.tryParse(val) == null) {
                          return "Enter valid price";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _sellingPriceController,
                      label: "Selling Price (Rs.)",
                      hint: "e.g. 175000",
                      prefixIcon: Icons.sell,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      validator: (val) {
                        if (val == null || double.tryParse(val) == null) {
                          return "Enter valid price";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Live Profit Indicator Card
              if (_purchasePrice > 0 && _sellingPrice > 0)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _profit >= 0
                        ? const Color(0xFF10B981).withOpacity(0.12)
                        : const Color(0xFFEF4444).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _profit >= 0
                          ? const Color(0xFF10B981).withOpacity(0.3)
                          : const Color(0xFFEF4444).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _profit >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: _profit >= 0
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _profit >= 0 ? "Expected Profit:" : "Selling at Loss:",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _profit >= 0
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Rs. ${_profit.toStringAsFixed(0)} (${_profitMargin.toStringAsFixed(1)}%)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _profit >= 0
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _notesController,
                label: "Additional Notes / Accessories Included",
                hint: "e.g. Box & charger included, battery health 92%",
                prefixIcon: Icons.notes,
                maxLines: 2,
              ),
              const SizedBox(height: 28),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _saveDevice,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.add_shopping_cart),
                  label: Text(
                    _isSubmitting ? "Saving Device..." : "Add to Stock Inventory",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
