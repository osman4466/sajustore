import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/database/database_helper.dart';
import '../accounts/account_list_screen.dart';
import '../cash_sales/cash_sales_screen.dart';
import 'widgets/date_header_card.dart';
import 'widgets/summary_card.dart';

/// Main Dashboard Screen for Saju Confectionery.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedMonth = DateTime.now();
  bool isLoading = true;

  Map<String, double> todaySummary = {
    'totalSales': 0,
    'cashReceived': 0,
    'creditSales': 0,
  };

  Map<String, double> monthSummary = {
    'totalSales': 0,
    'cashReceived': 0,
    'creditSales': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    setState(() => isLoading = true);
    final todayPattern = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final monthPattern = '${DateFormat('yyyy-MM').format(selectedMonth)}%';

    final todayRes = await DatabaseHelper.instance.getSalesSummary(todayPattern);
    final monthRes = await DatabaseHelper.instance.getSalesSummary(monthPattern);

    if (mounted) {
      setState(() {
        todaySummary = todayRes;
        monthSummary = monthRes;
        isLoading = false;
      });
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + delta,
        1,
      );
    });
    _loadSummaries();
  }

  Future<void> _navigateTo(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    // Refresh dashboard calculations after returning from cash or account sales
    if (mounted) {
      _loadSummaries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: const [
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            SizedBox(height: 2),
            Text(
              AppStrings.appSubtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSummaries,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppStyles.p12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Multi-calendar Date header (Bangla, English, Hijri)
              DateHeaderCard(date: DateTime.now()),
              const SizedBox(height: AppStyles.p12),

              // Action Buttons: Cash Sales & Customer Accounts
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateTo(const CashSalesScreen()),
                      icon: const Icon(Icons.point_of_sale),
                      label: const Text(AppStrings.cashSalesTitle),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppStyles.p16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppStyles.p12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateTo(const AccountListScreen()),
                      icon: const Icon(Icons.people_alt_outlined),
                      label: const Text(AppStrings.accountSalesTitle),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppStyles.p16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.p16),

              // Today's Sales Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppStyles.p12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.today, size: 18, color: AppColors.primary),
                          SizedBox(width: AppStyles.p8),
                          Text(
                            AppStrings.todaySummary,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppStyles.p12),
                      SalesSummarySection(
                        totalSales: todaySummary['totalSales'] ?? 0,
                        cashReceived: todaySummary['cashReceived'] ?? 0,
                        creditSales: todaySummary['creditSales'] ?? 0,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppStyles.p16),

              // Monthly Sales Summary Card with Month Switcher
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppStyles.p12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            tooltip: 'পূর্ববর্তী মাস',
                            onPressed: () => _changeMonth(-1),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                size: 18,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: AppStyles.p8),
                              Text(
                                DateFormat('MMMM yyyy').format(selectedMonth),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            tooltip: 'পরবর্তী মাস',
                            onPressed: () => _changeMonth(1),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppStyles.p8),
                      SalesSummarySection(
                        totalSales: monthSummary['totalSales'] ?? 0,
                        cashReceived: monthSummary['cashReceived'] ?? 0,
                        creditSales: monthSummary['creditSales'] ?? 0,
                      ),
                    ],
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
