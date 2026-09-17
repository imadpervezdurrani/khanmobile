import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';
import 'add_expense_dialog.dart';

class ExpensesView extends StatelessWidget {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final expenses = provider.filteredExpenses;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Shop Expenses Management"),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddExpenseDialog(),
              );
            },
            backgroundColor: const Color(0xFFEF4444),
            icon: const Icon(Icons.add),
            label: const Text("Add Expense"),
          ),
          body: Column(
            children: [
              // Monthly & Overall Summary Banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2541) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A395E) : const Color(0xFFFECACA),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryBlock(
                      "Today's Expenses",
                      currencyFormat.format(provider.todayExpenses),
                      const Color(0xFFF59E0B),
                      isDark,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: isDark ? const Color(0xFF2A395E) : const Color(0xFFE2E8F0),
                    ),
                    _summaryBlock(
                      "This Month",
                      currencyFormat.format(provider.thisMonthExpenses),
                      const Color(0xFFEF4444),
                      isDark,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: isDark ? const Color(0xFF2A395E) : const Color(0xFFE2E8F0),
                    ),
                    _summaryBlock(
                      "Total Expenses",
                      currencyFormat.format(provider.totalExpenses),
                      const Color(0xFF64748B),
                      isDark,
                    ),
                  ],
                ),
              ),

              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _categoryChip(context, "All", provider.selectedCategory == 'All',
                        () => provider.setSelectedCategory('All')),
                    const SizedBox(width: 8),
                    ...ExpenseModel.categories.map((cat) {
                      final isSelected = provider.selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _categoryChip(context, cat, isSelected,
                            () => provider.setSelectedCategory(cat)),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Expense List
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : expenses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.money_off_csred_outlined,
                                    size: 54, color: theme.disabledColor),
                                const SizedBox(height: 12),
                                Text(
                                  "No expenses recorded",
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Tap 'Add Expense' to record rent, bills, or salaries",
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            itemCount: expenses.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final expense = expenses[index];
                              return _buildExpenseCard(
                                  context, expense, currencyFormat, isDark);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryBlock(
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

  Widget _categoryChip(BuildContext context, String label, bool isSelected,
      VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }

  Widget _buildExpenseCard(BuildContext context, ExpenseModel expense,
      NumberFormat currencyFormat, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A395E) : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_outlined,
                color: Color(0xFFEF4444), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0B132B)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        expense.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM yyyy').format(expense.date),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (expense.notes != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    expense.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "- ${currencyFormat.format(expense.amount)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                expense.paymentMethod,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
