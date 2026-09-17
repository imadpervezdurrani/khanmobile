import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory StatusBadge.forStock(String status) {
    if (status == 'in_stock') {
      return const StatusBadge(
        label: 'In Stock',
        color: Color(0xFF10B981), // Emerald
        icon: Icons.check_circle_outline,
      );
    } else {
      return const StatusBadge(
        label: 'Sold',
        color: Color(0xFF64748B), // Slate Grey
        icon: Icons.sell_outlined,
      );
    }
  }

  factory StatusBadge.forCondition(String condition) {
    if (condition.toLowerCase() == 'new') {
      return const StatusBadge(
        label: 'Brand New',
        color: Color(0xFF0284C7), // Blue
        icon: Icons.verified_outlined,
      );
    } else {
      return const StatusBadge(
        label: 'Used',
        color: Color(0xFFF59E0B), // Amber
        icon: Icons.restore,
      );
    }
  }

  factory StatusBadge.forPayable(double balanceDue) {
    if (balanceDue > 0.01) {
      return StatusBadge(
        label: 'Payable Due',
        color: const Color(0xFFEF4444), // Red
        icon: Icons.warning_amber_rounded,
      );
    } else {
      return const StatusBadge(
        label: 'All Cleared',
        color: Color(0xFF10B981), // Green
        icon: Icons.check_circle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
