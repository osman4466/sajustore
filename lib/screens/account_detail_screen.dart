import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../models/sale_transaction.dart';
import '../db/database_helper.dart';
import 'add_account_sale_screen.dart';

class AccountDetailScreen extends StatefulWidget {
  final Account account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  List<SaleTransaction> transactions = [];
  late Account currentAccount;

  @override
  void initState() {
    super.initState();
    currentAccount = widget.account;
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final result = await DatabaseHelper.instance.getAccountTransactions(
      currentAccount.id!,
    );
    setState(() {
      transactions = result;
    });
  }

  double get totalAmount {
    double total = 0;
    for (var t in transactions) {
      if (t.type == 'payment') {
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
      builder: (context) {
        return AlertDialog(
          title: const Text('টাকা জমা'),
          content: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'কত টাকা জমা দিলেন'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                if (amount == null || amount <= 0) {
                  return;
                }
                final now = DateTime.now();
                final payment = SaleTransaction(
                  type: 'payment',
                  accountId: currentAccount.id,
                  totalAmount: amount,
                  date: DateFormat('dd-MM-yyyy, hh:mm a').format(now),
                  sortableDate: DateFormat('yyyy-MM-dd').format(now),
                );
                await DatabaseHelper.instance.insertTransaction(payment);
                if (mounted) {
                  Navigator.pop(context);
                  _loadTransactions();
                }
              },
              child: const Text('সেভ করুন'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDetails(SaleTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('জমার বিবরণ'),
          content: Text(
            '${transaction.date}\nজমা হয়েছে: ৳ ${transaction.totalAmount.toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('বন্ধ করুন'),
            ),
          ],
        );
      },
    );
  }

  // গ্রাহকের নাম ও ফোন নম্বর এডিট করার ডায়ালগ
  void _showEditAccountDialog() {
    final nameController = TextEditingController(text: currentAccount.name);
    final phoneController = TextEditingController(
      text: currentAccount.phone ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('গ্রাহকের তথ্য এডিট করুন'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'গ্রাহকের নাম'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'মোবাইল নাম্বার (ঐচ্ছিক)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  return;
                }
                final updatedAccount = Account(
                  id: currentAccount.id,
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim().isEmpty
                      ? null
                      : phoneController.text.trim(),
                );
                await DatabaseHelper.instance.updateAccount(updatedAccount);
                setState(() {
                  currentAccount = updatedAccount;
                });
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('সেভ করুন'),
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('লেনদেনের বিবরণ - ${transaction.date}'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return ListTile(
                        dense: true,
                        leading: Text('${index + 1}.'),
                        title: Text(sale.productName),
                        trailing: Text('৳ ${sale.amount.toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'মোট: ৳ ${transaction.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
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
              child: const Text('এডিট করুন'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('বন্ধ করুন'),
            ),
          ],
        );
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
            icon: const Icon(Icons.edit),
            tooltip: 'এডিট করুন',
            onPressed: _showEditAccountDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                if (currentAccount.phone != null &&
                    currentAccount.phone!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '📞 ${currentAccount.phone}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                const Text('মোট বাকি', style: TextStyle(fontSize: 14)),
                Text(
                  '৳ ${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('কোনো এন্ট্রি নেই'))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final isPayment = transaction.type == 'payment';
                      return ListTile(
                        leading: Icon(
                          isPayment ? Icons.arrow_downward : Icons.receipt_long,
                          color: isPayment ? Colors.green : Colors.blue,
                        ),
                        title: Text(transaction.date),
                        subtitle: isPayment ? const Text('জমা') : null,
                        trailing: Text(
                          '৳ ${transaction.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isPayment ? Colors.green : Colors.blue,
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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _goToAddSaleScreen,
                  icon: const Icon(Icons.add),
                  label: const Text('নতুন এন্ট্রি'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showAddPaymentDialog,
                  icon: const Icon(Icons.payments),
                  label: const Text('টাকা জমা'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
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
