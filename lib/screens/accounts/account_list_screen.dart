import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/date_helper.dart';
import '../../models/account.dart';
import '../common/widgets/confirm_dialog.dart';
import 'account_detail_screen.dart';

/// Screen listing customer accounts with search and total outstanding dues.
class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  List<Account> accounts = [];
  Map<int, double> accountTotals = {};
  String searchQuery = '';
  bool isLoading = true;

  double get grandTotal {
    return accountTotals.values.fold(0.0, (sum, val) => sum + val);
  }

  List<Account> get filteredAccounts {
    if (searchQuery.trim().isEmpty) return accounts;
    final q = searchQuery.toLowerCase().trim();
    return accounts.where((acc) {
      final nameMatches = acc.name.toLowerCase().contains(q);
      final phoneMatches = acc.phone != null && acc.phone!.toLowerCase().contains(q);
      return nameMatches || phoneMatches;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => isLoading = true);
    final result = await DatabaseHelper.instance.getAllAccounts();
    final totals = await DatabaseHelper.instance.getAllAccountDues();
    if (mounted) {
      setState(() {
        accounts = result;
        accountTotals = totals;
        isLoading = false;
      });
    }
  }

  void _showAddAccountDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(AppStrings.newAccount),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                if (name.isNotEmpty) {
                  final account = Account(
                    name: name,
                    phone: phone.isEmpty ? null : phone,
                  );
                  await DatabaseHelper.instance.insertAccount(account);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
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

  Future<void> _deleteAccount(Account account) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      message: '${account.name} এর একাউন্ট ও সকল পূর্বের হিসাব স্থায়ীভাবে মুছে ফেলতে চান?',
    );
    if (confirmed && mounted) {
      await DatabaseHelper.instance.deleteAccount(account.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${account.name} মুছে ফেলা হয়েছে')),
      );
      _loadAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayList = filteredAccounts;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.accountsTitle),
      ),
      body: Column(
        children: [
          // Grand Total Due Header Card
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
                const Text(
                  AppStrings.totalDue,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateHelper.formatCurrency(grandTotal),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppStyles.p12,
              AppStyles.p12,
              AppStyles.p12,
              AppStyles.p4,
            ),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: AppStrings.searchCustomer,
                prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => setState(() => searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),

          // Account List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 56,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: AppStyles.p8),
                            Text(
                              searchQuery.isEmpty
                                  ? AppStrings.noAccounts
                                  : 'কোনো ফলাফল পাওয়া যায়নি',
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppStyles.p8,
                        ),
                        itemCount: displayList.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final account = displayList[index];
                          final due = accountTotals[account.id] ?? 0.0;
                          final hasDue = due > 0;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: hasDue
                                  ? AppColors.secondaryLight
                                  : AppColors.primaryLight,
                              foregroundColor: hasDue
                                  ? AppColors.secondary
                                  : AppColors.primary,
                              child: Text(
                                account.name.isNotEmpty
                                    ? account.name.characters.first
                                    : '?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              account.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: account.phone != null &&
                                    account.phone!.isNotEmpty
                                ? Text('📞 ${account.phone}')
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateHelper.formatCurrency(due),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: hasDue
                                        ? AppColors.secondary
                                        : AppColors.success,
                                  ),
                                ),
                                const SizedBox(width: AppStyles.p4),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textHint,
                                ),
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
                              _loadAccounts();
                            },
                            onLongPress: () => _deleteAccount(account),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAccountDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('নতুন গ্রাহক'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }
}
