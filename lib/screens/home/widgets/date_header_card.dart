import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/date_helper.dart';

/// Clean, overflow-safe card displaying the 3 calendar dates (Bangla, English, Hijri).
class DateHeaderCard extends StatelessWidget {
  final DateTime date;

  const DateHeaderCard({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.p12,
        vertical: AppStyles.p8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppStyles.radiusMedium,
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppStyles.p12,
        runSpacing: AppStyles.p4,
        children: [
          _DateBadge(
            icon: Icons.calendar_today,
            label: DateHelper.getEnglishDate(date),
          ),
          _DateBadge(
            icon: Icons.wb_sunny_outlined,
            label: DateHelper.getBanglaDate(date),
          ),
          _DateBadge(
            icon: Icons.nights_stay_outlined,
            label: DateHelper.getHijriBanglaDate(date),
          ),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DateBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primaryDark),
        const SizedBox(width: AppStyles.p4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}
