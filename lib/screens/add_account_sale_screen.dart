import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/sale.dart';
import '../models/sale_transaction.dart';
import '../db/database_helper.dart';
import 'package:intl/intl.dart';

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

class ProductRow {
  final TextEditingController productController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
}

class _AddAccountSaleScreenState extends State<AddAccountSaleScreen> {
  List<ProductRow> rows = [ProductRow()];
  double total = 0;

  @override
  void initState() {
    super.initState();
    if (widget.editSales != null && widget.editSales!.isNotEmpty) {
      rows = widget.editSales!.map((sale) {
        final row = ProductRow();
        row.productController.text = sale.productName;
        row.amountController.text = sale.amount.toString();
        return row;
      }).toList();
      _calculateTotal();
    }
  }

  void _addRow() {
    setState(() {
      rows.add(ProductRow());
    });
  }

  void _removeRow(int index) {
    setState(() {
      rows.removeAt(index);
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    double sum = 0;
    for (var row in rows) {
      final value = double.tryParse(row.amountController.text);
      if (value != null) sum += value;
    }
    setState(() {
      total = sum;
    });
  }

  Future<void> _saveAll() async {
    final date =
        widget.editTransaction?.date ??
        DateFormat('dd-MM-yyyy, hh:mm a').format(DateTime.now());

    final sortableDate =
        widget.editTransaction?.sortableDate ??
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    final validRows = rows.where((row) {
      final name = row.productController.text.trim();
      final amount = double.tryParse(row.amountController.text.trim());
      return name.isNotEmpty && amount != null;
    }).toList();

    if (validRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অন্তত একটি পণ্যের নাম ও দাম দিন')),
      );
      return;
    }

    double transactionTotal = 0;
    for (var row in validRows) {
      transactionTotal += double.parse(row.amountController.text.trim());
    }

    int transactionId;
    if (widget.editTransaction != null) {
      transactionId = widget.editTransaction!.id!;
      final updatedTransaction = SaleTransaction(
        id: transactionId,
        type: 'account',
        accountId: widget.account.id,
        totalAmount: transactionTotal,
        date: date,
        sortableDate: sortableDate,
      );
      await DatabaseHelper.instance.updateTransaction(updatedTransaction);
      await DatabaseHelper.instance.deleteSalesForTransaction(transactionId);
    } else {
      final transaction = SaleTransaction(
        type: 'account',
        accountId: widget.account.id,
        totalAmount: transactionTotal,
        date: date,
        sortableDate: sortableDate,
      );
      transactionId = await DatabaseHelper.instance.insertTransaction(
        transaction,
      );
    }

    for (var row in validRows) {
      final sale = Sale(
        transactionId: transactionId,
        productName: row.productController.text.trim(),
        amount: double.parse(row.amountController.text.trim()),
      );
      await DatabaseHelper.instance.insertSale(sale);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    for (var row in rows) {
      row.productController.dispose();
      row.amountController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editTransaction != null
              ? 'এন্ট্রি এডিট করুন'
              : '${widget.account.name} - নতুন এন্ট্রি',
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                const Text('মোট', style: TextStyle(fontSize: 14)),
                Text(
                  '৳ ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final row = rows[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: row.productController,
                          decoration: const InputDecoration(
                            hintText: 'পণ্যের নাম',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: row.amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'দাম',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                          onChanged: (value) => _calculateTotal(),
                        ),
                      ),
                      if (rows.length > 1)
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _removeRow(index),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: _addRow,
              icon: const Icon(Icons.add),
              label: const Text('আরেকটি পণ্য'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: ElevatedButton(
              onPressed: _saveAll,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.editTransaction != null ? 'আপডেট করুন' : 'সব সেভ করুন',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
