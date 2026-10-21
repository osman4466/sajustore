import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/date_helper.dart';
import '../../models/account.dart';
import '../../models/sale_transaction.dart';
import '../common/widgets/confirm_dialog.dart';
import '../common/widgets/transaction_detail_dialog.dart';
import 'add_account_sale_screen.dart';

/// Screen displaying customer's transaction ledger (credit sales & payments).
class AccountDetailScreen extends StatefulWidget {
  final Account account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  late Account currentAccount;
  List<SaleTransaction> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentAccount = widget.account;
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => isLoading = true);
    final result = await DatabaseHelper.instance.getAccountTransactions(
      currentAccount.id!,
    );
    if (mounted) {
      setState(() {
        transactions = result;
        isLoading = false;
      });
    }
  }

  double get totalDue {
    double total = 0.0;
    for (final t in transactions) {
      if (t.isPayment) {
        total -= t.totalAmount;
      } else {
        total += t.totalAmount;
      }
    }
    return total;
  }

  void _goToAddSaleScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAccountSaleScreen(account: currentAccount),
      ),
    );
    _loadTransactions();
  }

  void _showAddPaymentDialog() {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.payments_outlined, color: AppColors.success),
              SizedBox(width: AppStyles.p8),
              Text(AppStrings.paymentDeposit),
            ],
          ),
          content: TextField(
            controller: amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: AppStrings.paymentAmount,
              prefixText: '৳ ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                if (amount != null && amount > 0) {
                  final now = DateTime.now();
                  final payment = SaleTransaction(
                    type: 'payment',
                    accountId: currentAccount.id,
                    totalAmount: amount,
                    date: DateHelper.formatDisplayDateTime(now),
                    sortableDate: DateHelper.formatSortableDate(now),
                  );
                  await DatabaseHelper.instance.insertTransaction(payment);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    _loadTransactions();
                  }
                }
              },
              child: const Text('জমা করুন'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDetails(SaleTransaction transaction) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('জমার বিবরণ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('তারিখ: ${transaction.date}'),
              const SizedBox(height: AppStyles.p8),
              Text(
                'জমা হয়েছে: ${DateHelper.formatCurrency(transaction.totalAmount)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: AppStrings.delete,
              onPressed: () async {
                final confirm = await ConfirmDialog.show(
                  context: context,
                  message: 'আপনি কি এই জমা লেনদেনটি মুছে ফেলতে চান?',
                );
                if (confirm && ctx.mounted) {
                  Navigator.pop(ctx);
                  await DatabaseHelper.instance.deleteTransaction(transaction.id!);
                  _loadTransactions();
                }
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.close),
            ),
          ],
        );
      },
    );
  }

  void _showEditAccountDialog() {
    final nameController = TextEditingController(text: currentAccount.name);
    final phoneController = TextEditingController(
      text: currentAccount.phone ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('গ্রাহকের তথ্য পরিবর্তন'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.customerName,
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: AppStyles.p12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: AppStrings.customerPhone,
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                if (name.isNotEmpty) {
                  final updated = currentAccount.copyWith(
                    name: name,
                    phone: phone.isEmpty ? null : phone,
                  );
                  await DatabaseHelper.instance.updateAccount(updated);
                  setState(() => currentAccount = updated);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                }
              },
              child: const Text(AppStrings.update),
            ),
          ],
        );
      },
    );
  }

  void _showTransactionDetails(SaleTransaction transaction) async {
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
            builder: (context) => AddAccountSaleScreen(
              account: currentAccount,
              editTransaction: transaction,
              editSales: sales,
            ),
          ),
        );
        _loadTransactions();
      },
      onDelete: () async {
        await DatabaseHelper.instance.deleteTransaction(transaction.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('লেনদেনটি মুছে ফেলা হয়েছে')),
          );
          _loadTransactions();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentAccount.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'গ্রাহক তথ্য এডিট',
            onPressed: _showEditAccountDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Total Due Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppStyles.p16),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              border: Border(
                bottom: BorderSide(color: AppColors.secondary.withAlpha(40)),
              ),
            ),
            child: Column(
              children: [
                if (currentAccount.phone != null &&
                    currentAccount.phone!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppStyles.p4),
                    child: Text(
                      '📞 ${currentAccount.phone}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const Text(
                  AppStrings.customerTotalDue,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateHelper.formatCurrency(totalDue),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: totalDue > 0 ? AppColors.secondary : AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          // Transaction Ledger List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : transactions.isEmpty
                    ? const Center(
                        child: Text(
                          AppStrings.noEntries,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppStyles.p8,
                        ),
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          final isPayment = transaction.isPayment;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isPayment
                                  ? AppColors.primaryLight
                                  : AppColors.secondaryLight,
                              child: Icon(
                                isPayment
                                    ? Icons.arrow_downward
                                    : Icons.assignment_outlined,
                                color: isPayment
                                    ? AppColors.success
                                    : AppColors.secondary,
                              ),
                            ),
                            title: Text(
                              transaction.date,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              isPayment ? 'টাকা জমা' : 'বাকিতে ক্রয়',
                              style: TextStyle(
                                fontSize: 12,
                                color: isPayment
                                    ? AppColors.success
                                    : AppColors.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              '${isPayment ? '-' : '+'} ${DateHelper.formatCurrency(transaction.totalAmount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isPayment
                                    ? AppColors.success
                                    : AppColors.secondary,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              if (isPayment) {
                                _showPaymentDetails(transaction);
                              } else {
                                _showTransactionDetails(transaction);
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.p12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _goToAddSaleScreen,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text(AppStrings.newEntry),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppStyles.p14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppStyles.p12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showAddPaymentDialog,
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text(AppStrings.paymentDeposit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppStyles.p14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
