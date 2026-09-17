class ProfitLossReport {
  final double totalRevenue;
  final double totalCostOfGoodsSold;
  final double totalExpenses;
  final int totalUnitsSold;
  final double inventoryCostInStock;
  final double inventoryRetailValue;
  final double totalSupplierPayable;
  final DateTime startDate;
  final DateTime endDate;

  ProfitLossReport({
    required this.totalRevenue,
    required this.totalCostOfGoodsSold,
    required this.totalExpenses,
    required this.totalUnitsSold,
    required this.inventoryCostInStock,
    required this.inventoryRetailValue,
    required this.totalSupplierPayable,
    required this.startDate,
    required this.endDate,
  });

  // Gross Profit = Revenue - COGS
  double get grossProfit => totalRevenue - totalCostOfGoodsSold;

  double get grossMarginPercentage =>
      totalRevenue > 0 ? (grossProfit / totalRevenue) * 100 : 0.0;

  // Net Profit / Loss = Gross Profit - Operating Expenses
  double get netProfit => grossProfit - totalExpenses;

  double get netProfitPercentage =>
      totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0.0;

  bool get isProfitable => netProfit >= 0;

  // Potential Profit locked in current inventory
  double get potentialStockProfit => inventoryRetailValue - inventoryCostInStock;
}
