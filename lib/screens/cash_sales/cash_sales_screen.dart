import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/date_helper.dart';
import '../../models/sale_transaction.dart';
import '../common/widgets/transaction_detail_dialog.dart';
import 'add_cash_sale_screen.dart';

/// Screen listing all cash transactions for the confectionery store.
class CashSalesScreen extends StatefulWidget {
  const CashSalesScreen({super.key});

  @override
  State<CashSalesScreen> createState() => _CashSalesScreenState();
}

class _CashSalesScreenState extends State<CashSalesScreen> {
  List<SaleTransaction> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCashTransactions();
  }

  Future<void> _loadCashTransactions() async {
    setState(() => isLoading = true);
    final result = await DatabaseHelper.instance.getCashTransactions();
    if (mounted) {
      setState(() {
        transactions = result;
        isLoading = false;
      });
    }
  }

  Future<void> _openAddCashSale() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCashSaleScreen()),
    );
    _loadCashTransactions();
  }

  Future<void> _showTransactionDetails(SaleTransaction transaction) async {
    final sales = await DatabaseHelper.instance.getSalesForTransaction(
      transaction.id!,
    );

    if (!mounted) return;

    await TransactionDetailDialog.show(
      context: context,
      transaction: transaction,
      sales: sales,
      onEdit: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCashSaleScreen(
              editTransaction: transaction,
              editSales: sales,
            ),
          ),
        );
        _loadCashTransactions();
      },
      onDelete: () async {
        await DatabaseHelper.instance.deleteTransaction(transaction.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('লেনদেনটি মুছে ফেলা হয়েছে')),
          );
          _loadCashTransactions();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cashSalesTitle),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: AppStyles.p12),
                      Text(
                        AppStrings.noCashSales,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppStyles.p4),
                      Text(
                        '+ চাপুন নতুন ক্যাশ সেল করতে',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: AppStyles.p8),
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: const Icon(
                          Icons.receipt_long,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        transaction.date,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'রশিদ #${transaction.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateHelper.formatCurrency(transaction.totalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: AppStyles.p4),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textHint,
                          ),
                        ],
                      ),
                      onTap: () => _showTransactionDetails(transaction),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCashSale,
        icon: const Icon(Icons.add),
        label: const Text('নতুন ক্যাশ সেল'),
      ),
    );
  }
}
