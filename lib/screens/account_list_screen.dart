import 'package:flutter/material.dart';
import '../models/account.dart';
import '../db/database_helper.dart';
import 'account_detail_screen.dart';

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  List<Account> accounts = [];
  Map<int, double> accountTotals = {};

  double get grandTotal {
    return accountTotals.values.fold(0, (sum, val) => sum + val);
  }

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final result = await DatabaseHelper.instance.getAllAccounts();
    final totals = await DatabaseHelper.instance.getAllAccountDues();
    setState(() {
      accounts = result;
      accountTotals = totals;
    });
  }

  void _showAddAccountDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('নতুন একাউন্ট তৈরি করুন'),
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
                if (nameController.text.isNotEmpty) {
                  final account = Account(
                    name: nameController.text,
                    phone: phoneController.text.isEmpty
                        ? null
                        : phoneController.text,
                  );
                  await DatabaseHelper.instance.insertAccount(account);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadAccounts();
                  }
                }
              },
              child: const Text('তৈরি করুন'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('একাউন্ট তালিকা')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                const Text('সর্বমোট বাকি', style: TextStyle(fontSize: 14)),
                Text(
                  '৳ ${grandTotal.toStringAsFixed(2)}',
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
            child: accounts.isEmpty
                ? const Center(
                    child: Text(
                      'কোনো একাউন্ট নেই। + চেপে নতুন একাউন্ট তৈরি করুন',
                    ),
                  )
                : ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(account.name),
                        subtitle: account.phone != null
                            ? Text(account.phone!)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '৳ ${(accountTotals[account.id] ?? 0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AccountDetailScreen(account: account),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAccountDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
