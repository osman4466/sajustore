import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/date_helper.dart';
import '../../models/account.dart';
import '../../models/sale.dart';
import '../../models/sale_transaction.dart';
import '../common/widgets/product_entry_item.dart';

/// Screen for adding or editing a multi-item confectionery credit sale for a customer account.
class AddAccountSaleScreen extends StatefulWidget {
  final Account account;
  final SaleTransaction? editTransaction;
  final List<Sale>? editSales;

  const AddAccountSaleScreen({
    super.key,
    required this.account,
    this.editTransaction,
    this.editSales,
  });

  @override
  State<AddAccountSaleScreen> createState() => _AddAccountSaleScreenState();
}

class _AddAccountSaleScreenState extends State<AddAccountSaleScreen> {
  final List<ProductRowModel> rows = [];
  double total = 0.0;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editSales != null && widget.editSales!.isNotEmpty) {
      for (final sale in widget.editSales!) {
        rows.add(
          ProductRowModel(
            initialName: sale.productName,
            initialAmount: sale.amount % 1 == 0
                ? sale.amount.toInt().toString()
                : sale.amount.toString(),
          ),
        );
      }
    } else {
      rows.add(ProductRowModel());
    }
    _calculateTotal();
  }

  void _addRow() {
    setState(() {
      rows.add(ProductRowModel());
    });
  }

  void _removeRow(int index) {
    if (rows.length > 1) {
      setState(() {
        final removed = rows.removeAt(index);
        removed.dispose();
      });
      _calculateTotal();
    }
  }

  void _calculateTotal() {
    double sum = 0;
    for (final row in rows) {
      sum += (row.amount ?? 0);
    }
    setState(() {
      total = sum;
    });
  }

  Future<void> _saveAccountSale() async {
    final validRows = rows.where((row) => row.isValid).toList();

    if (validRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.validationAtLeastOne),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    final now = DateTime.now();
    final displayDate = widget.editTransaction?.date ??
        DateHelper.formatDisplayDateTime(now);
    final sortableDate = widget.editTransaction?.sortableDate ??
        DateHelper.formatSortableDate(now);

    final items = validRows.map((row) {
      return Sale(
        transactionId: widget.editTransaction?.id ?? 0,
        productName: row.name,
        amount: row.amount!,
      );
    }).toList();

    try {
      if (widget.editTransaction != null) {
        final updated = widget.editTransaction!.copyWith(
          totalAmount: total,
          date: displayDate,
          sortableDate: sortableDate,
        );
        await DatabaseHelper.instance.updateTransactionWithSales(
          transaction: updated,
          sales: items,
        );
      } else {
        final transaction = SaleTransaction(
          type: 'account',
          accountId: widget.account.id,
          totalAmount: total,
          date: displayDate,
          sortableDate: sortableDate,
        );
        await DatabaseHelper.instance.saveTransactionWithSales(
          transaction: transaction,
          sales: items,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('সংরক্ষণ ব্যর্থ হয়েছে: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    for (final row in rows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editTransaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? AppStrings.editAccountSaleTitle
              : '${widget.account.name} - বাকি বিক্রয়',
        ),
      ),
      body: Column(
        children: [
          // Total Credit Header Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppStyles.p16,
              horizontal: AppStyles.p20,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              border: Border(
                bottom: BorderSide(color: AppColors.secondary.withAlpha(40)),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${widget.account.name} এর নতুন বাকির পরিমাণ',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateHelper.formatCurrency(total),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),

          // Dynamic Product Rows List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppStyles.p12),
              itemCount: rows.length,
              itemBuilder: (context, index) {
                return ProductRowWidget(
                  index: index,
                  model: rows[index],
                  onAmountChanged: _calculateTotal,
                  onRemove: rows.length > 1 ? () => _removeRow(index) : null,
                );
              },
            ),
          ),

          // Add Row Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.p12),
            child: OutlinedButton.icon(
              onPressed: _addRow,
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addProduct),
            ),
          ),
          const SizedBox(height: AppStyles.p8),

          // Save / Update Action Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppStyles.p12,
                0,
                AppStyles.p12,
                AppStyles.p12,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : _saveAccountSale,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    isSaving
                        ? 'সংরক্ষণ হচ্ছে...'
                        : (isEditing ? AppStrings.update : AppStrings.saveAll),
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppStyles.p14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
