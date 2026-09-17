import 'package:flutter/material.dart';
import '../models/sale_model.dart';
import '../models/expense_model.dart';
import '../models/profit_loss_report.dart';
import 'sales_provider.dart';
import 'expense_provider.dart';
import 'inventory_provider.dart';
import 'supplier_provider.dart';

enum ReportPeriod { today, thisWeek, thisMonth, thisYear, allTime }

class ReportsProvider with ChangeNotifier {
  ReportPeriod _selectedPeriod = ReportPeriod.thisMonth;

  ReportPeriod get selectedPeriod => _selectedPeriod;

  void setPeriod(ReportPeriod period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  // Generates the comprehensive Profit & Loss Report based on other providers
  ProfitLossReport generateReport({
    required SalesProvider salesProvider,
    required ExpenseProvider expenseProvider,
    required InventoryProvider inventoryProvider,
    required SupplierProvider supplierProvider,
  }) {
    final now = DateTime.now();
    DateTime startDate;
    final DateTime endDate = now;

    switch (_selectedPeriod) {
      case ReportPeriod.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case ReportPeriod.thisWeek:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case ReportPeriod.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case ReportPeriod.thisYear:
        startDate = DateTime(now.year, 1, 1);
        break;
      case ReportPeriod.allTime:
        startDate = DateTime(2020, 1, 1);
        break;
    }

    // Filter sales in the period
    final periodSales = salesProvider.allSales.where((s) {
      return s.saleDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          s.saleDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    // Filter expenses in the period
    final periodExpenses = expenseProvider.allExpenses.where((e) {
      return e.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          e.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    final totalRevenue =
        periodSales.fold(0.0, (sum, s) => sum + s.finalPrice);
    final totalCOGS =
        periodSales.fold(0.0, (sum, s) => sum + s.purchasePrice);
    final totalExpenses =
        periodExpenses.fold(0.0, (sum, e) => sum + e.amount);

    return ProfitLossReport(
      totalRevenue: totalRevenue,
      totalCostOfGoodsSold: totalCOGS,
      totalExpenses: totalExpenses,
      totalUnitsSold: periodSales.length,
      inventoryCostInStock: inventoryProvider.totalStockCostValue,
      inventoryRetailValue: inventoryProvider.totalStockRetailValue,
      totalSupplierPayable: supplierProvider.totalAccountsPayable,
      startDate: startDate,
      endDate: endDate,
    );
  }

  String get periodDisplayName {
    switch (_selectedPeriod) {
      case ReportPeriod.today:
        return "Today";
      case ReportPeriod.thisWeek:
        return "This Week";
      case ReportPeriod.thisMonth:
        return "This Month";
      case ReportPeriod.thisYear:
        return "This Year";
      case ReportPeriod.allTime:
        return "All Time";
    }
  }
}
