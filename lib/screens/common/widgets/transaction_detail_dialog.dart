import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/date_helper.dart';
import '../../../models/sale.dart';
import '../../../models/sale_transaction.dart';
import 'confirm_dialog.dart';

/// Modal dialog displaying itemized receipt breakdown for any transaction.
class TransactionDetailDialog extends StatelessWidget {
  final SaleTransaction transaction;
  final List<Sale> sales;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionDetailDialog({
    super.key,
    required this.transaction,
    required this.sales,
    required this.onEdit,
    required this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required SaleTransaction transaction,
    required List<Sale> sales,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => TransactionDetailDialog(
        transaction: transaction,
        sales: sales,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Row(
        children: [
          Icon(
            transaction.isCash ? Icons.receipt_long : Icons.assignment_outlined,
            color: transaction.isCash ? AppColors.primary : AppColors.secondary,
          ),
          const SizedBox(width: AppStyles.p8),
          Expanded(
            child: Text(
              'রশিদ বিবরণ (${transaction.date})',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            if (sales.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppStyles.p16),
                child: Text('কোনো পণ্যের বিবরণ পাওয়া যায়নি'),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: sales.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Text(
                        '${index + 1}.',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      title: Text(sale.productName),
                      trailing: Text(
                        DateHelper.formatCurrency(sale.amount),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
              ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppStyles.p8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'মোট:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateHelper.formatCurrency(transaction.totalAmount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: transaction.isCash
                          ? AppColors.primary
                          : AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          tooltip: AppStrings.delete,
          onPressed: () async {
            final confirm = await ConfirmDialog.show(
              context: context,
              message: AppStrings.confirmDeleteTransaction,
            );
            if (confirm && context.mounted) {
              Navigator.pop(context);
              onDelete();
            }
          },
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onEdit();
          },
          child: const Text(AppStrings.edit),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.close),
        ),
      ],
    );
  }
}
