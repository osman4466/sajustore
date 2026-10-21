import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../utils/date_helper.dart';
import 'account_list_screen.dart';

import 'cash_sales_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedMonth = DateTime.now();
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
    _loadTodaySummary();
    _loadMonthSummary();
  }

  Future<void> _loadTodaySummary() async {
    final todayPattern = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final result = await DatabaseHelper.instance.getSalesSummary(todayPattern);
    setState(() {
      todaySummary = result;
    });
  }

  Future<void> _loadMonthSummary() async {
    final monthPattern = '${DateFormat('yyyy-MM').format(selectedMonth)}%';
    final result = await DatabaseHelper.instance.getSalesSummary(monthPattern);
    setState(() {
      monthSummary = result;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + delta,
        1,
      );
    });
    _loadMonthSummary();
  }

  Widget _buildSummarySection(double total, double cash, double credit) {
    return Column(
      children: [
        _buildSummaryBox('মোট বিক্রয়', total, Colors.green, fullWidth: true),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSummaryBox('ক্যাশ বিক্রয়', cash, Colors.blue),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryBox('বাকির বিক্রয়', credit, Colors.orange),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryBox(
    String label,
    double amount,
    Color color, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: fullWidth ? 13 : 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '৳ ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: fullWidth ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade100,
        toolbarHeight: 68,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Saju Store',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 18, 139, 22),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateHelper.getBanglaDate(DateTime.now()),
                  style: const TextStyle(fontSize: 12.5),
                ),
                Text(
                  DateHelper.getEnglishDate(DateTime.now()),
                  style: const TextStyle(fontSize: 12.5),
                ),
                Text(
                  DateHelper.getHijriBanglaDate(DateTime.now()),
                  style: const TextStyle(fontSize: 12.5),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CashSalesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.money),
                    label: const Text('ক্যাশ সেল'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountListScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people),
                    label: const Text('একাউন্ট সেল'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                const Text(
                  'আজকের হিসাব',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                _buildSummarySection(
                  todaySummary['totalSales'] ?? 0,
                  todaySummary['cashReceived'] ?? 0,
                  todaySummary['creditSales'] ?? 0,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(selectedMonth),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSummarySection(
                  monthSummary['totalSales'] ?? 0,
                  monthSummary['cashReceived'] ?? 0,
                  monthSummary['creditSales'] ?? 0,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
