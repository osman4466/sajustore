import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/date_helper.dart';

/// Section rendering total, cash, and credit sales metrics.
class SalesSummarySection extends StatelessWidget {
  final double totalSales;
  final double cashReceived;
  final double creditSales;

  const SalesSummarySection({
    super.key,
    required this.totalSales,
    required this.cashReceived,
    required this.creditSales,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MetricBox(
          label: AppStrings.totalSales,
          amount: totalSales,
          color: AppColors.primary,
          fullWidth: true,
          icon: Icons.storefront,
        ),
        const SizedBox(height: AppStyles.p8),
        Row(
          children: [
            Expanded(
              child: _MetricBox(
                label: AppStrings.cashReceived,
                amount: cashReceived,
                color: AppColors.secondary,
                icon: Icons.payments_outlined,
              ),
            ),
            const SizedBox(width: AppStyles.p8),
            Expanded(
              child: _MetricBox(
                label: AppStrings.creditSales,
                amount: creditSales,
                color: AppColors.accentOrange,
                icon: Icons.assignment_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool fullWidth;
  final IconData icon;

  const _MetricBox({
    required this.label,
    required this.amount,
    required this.color,
    this.fullWidth = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.symmetric(
        vertical: fullWidth ? AppStyles.p12 : AppStyles.p8,
        horizontal: AppStyles.p8,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: AppStyles.radiusMedium,
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: AppStyles.p4),
              Text(
                label,
                style: TextStyle(
                  fontSize: fullWidth ? 13 : 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: AppStyles.p4),
          Text(
            DateHelper.formatCurrency(amount),
            style: TextStyle(
              fontSize: fullWidth ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
