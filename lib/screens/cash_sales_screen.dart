import 'package:flutter/material.dart';
import '../models/sale_transaction.dart';
import '../db/database_helper.dart';
import 'add_cash_sale_screen.dart';

class CashSalesScreen extends StatefulWidget {
  const CashSalesScreen({super.key});

  @override
  State<CashSalesScreen> createState() => _CashSalesScreenState();
}

class _CashSalesScreenState extends State<CashSalesScreen> {
  List<SaleTransaction> cashTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadCashTransactions();
  }

  Future<void> _loadCashTransactions() async {
    final result = await DatabaseHelper.instance.getCashTransactions();
    setState(() {
      cashTransactions = result;
    });
  }

  void _goToAddSaleScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCashSaleScreen()),
    );
    _loadCashTransactions();
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
                    builder: (context) => AddCashSaleScreen(
                      editTransaction: transaction,
                      editSales: sales,
                    ),
                  ),
                );
                _loadCashTransactions();
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
      appBar: AppBar(title: const Text('ক্যাশ সেল')),
      body: cashTransactions.isEmpty
          ? const Center(child: Text('কোনো ক্যাশ সেল নেই'))
          : ListView.builder(
              itemCount: cashTransactions.length,
              itemBuilder: (context, index) {
                final transaction = cashTransactions[index];
                return ListTile(
                  leading: const Icon(Icons.receipt_long, color: Colors.green),
                  title: Text(transaction.date),
                  trailing: Text(
                    '৳ ${transaction.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () => _showTransactionDetails(transaction),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddSaleScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
