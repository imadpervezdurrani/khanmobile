import 'package:flutter/material.dart';
import 'dashboard/dashboard_view.dart';
import 'inventory/inventory_list_view.dart';
import 'sales/sales_view.dart';
import 'expenses/expenses_view.dart';
import 'suppliers/suppliers_view.dart';
import 'reports/profit_loss_view.dart';
import 'settings/settings_view.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  void _onTabSelect(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWideScreen = MediaQuery.of(context).size.width >= 800;

    final List<Widget> pages = [
      DashboardView(onNavigateTab: _onTabSelect),
      const InventoryListView(),
      const SalesView(),
      const ExpensesView(),
      const SuppliersView(),
      const ProfitLossView(),
      const SettingsView(),
    ];

    final List<NavigationDestination> destinations = const [
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      NavigationDestination(
        icon: Icon(Icons.smartphone_outlined),
        selectedIcon: Icon(Icons.smartphone),
        label: 'Stock',
      ),
      NavigationDestination(
        icon: Icon(Icons.point_of_sale_outlined),
        selectedIcon: Icon(Icons.point_of_sale),
        label: 'POS Sales',
      ),
      NavigationDestination(
        icon: Icon(Icons.money_off_outlined),
        selectedIcon: Icon(Icons.money_off),
        label: 'Expenses',
      ),
      NavigationDestination(
        icon: Icon(Icons.business_outlined),
        selectedIcon: Icon(Icons.business),
        label: 'Khata',
      ),
      NavigationDestination(
        icon: Icon(Icons.assessment_outlined),
        selectedIcon: Icon(Icons.assessment),
        label: 'P&L Reports',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];

    if (isWideScreen) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabSelect,
              labelType: NavigationRailLabelType.all,
              backgroundColor: isDark ? const Color(0xFF0B132B) : Colors.white,
              selectedIconTheme: const IconThemeData(color: Color(0xFF0284C7)),
              selectedLabelTextStyle: const TextStyle(
                color: Color(0xFF0284C7),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.smartphone_outlined),
                  selectedIcon: Icon(Icons.smartphone),
                  label: Text('Stock'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.point_of_sale_outlined),
                  selectedIcon: Icon(Icons.point_of_sale),
                  label: Text('POS'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.money_off_outlined),
                  selectedIcon: Icon(Icons.money_off),
                  label: Text('Expenses'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.business_outlined),
                  selectedIcon: Icon(Icons.business),
                  label: Text('Khata'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assessment_outlined),
                  selectedIcon: Icon(Icons.assessment),
                  label: Text('P&L Reports'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: pages[_currentIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelect,
        elevation: 4,
        backgroundColor: isDark ? const Color(0xFF0B132B) : Colors.white,
        indicatorColor: const Color(0xFF0284C7).withOpacity(0.2),
        destinations: destinations,
      ),
    );
  }
}
