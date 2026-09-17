import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/custom_text_field.dart';

class AddSupplierDialog extends StatefulWidget {
  const AddSupplierDialog({super.key});

  @override
  State<AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends State<AddSupplierDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _addressController = TextEditingController();
  final _initialBilledController = TextEditingController(text: '0');
  final _initialPaidController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  bool _isSaving = false;

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await Provider.of<SupplierProvider>(context, listen: false).addSupplier(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        companyName: _companyController.text.trim(),
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        initialBilled: double.tryParse(_initialBilledController.text) ?? 0.0,
        initialPaid: double.tryParse(_initialPaidController.text) ?? 0.0,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Supplier added successfully!"),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error adding supplier: $e"),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.business,
                              color: Color(0xFF6366F1), size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Add Supplier / Khata",
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

                CustomTextField(
                  controller: _companyController,
                  label: "Company / Shop Name",
                  hint: "e.g. Tariq Wholesale Mobiles, Star Telecom",
                  prefixIcon: Icons.store,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _nameController,
                        label: "Contact Person",
                        hint: "e.g. Tariq Mehmood",
                        prefixIcon: Icons.person_outline,
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _phoneController,
                        label: "Phone Number",
                        hint: "0300-1234567",
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? "Required" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _addressController,
                  label: "Shop Address / Market Location",
                  hint: "e.g. Shop # 42, Hafeez Centre, Lahore",
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),

                // Opening Balance
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _initialBilledController,
                        label: "Opening Billed (Rs.)",
                        hint: "0",
                        prefixIcon: Icons.receipt_long,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _initialPaidController,
                        label: "Opening Paid (Rs.)",
                        hint: "0",
                        prefixIcon: Icons.payment,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _notesController,
                  label: "Terms / Notes",
                  hint: "e.g. 15-day credit cycle, returns allowed within 3 days",
                  prefixIcon: Icons.notes,
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSaving ? null : _saveSupplier,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      _isSaving ? "Saving..." : "Add Supplier Account",
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
