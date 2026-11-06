import 'dart:math';
import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../utils.dart';

class StatisticsScreen extends StatefulWidget {
  final List<TransactionModel> transactions;

  const StatisticsScreen({super.key, required this.transactions});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedTimeTab = 0;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final expenseTransactions = widget.transactions.where((item) {
      if (!item.isExpense) return false;
      if (_selectedTimeTab == 0) {
        return item.date.month == now.month && item.date.year == now.year;
      } else if (_selectedTimeTab == 1) {
        final lastMonth = DateTime(now.year, now.month - 1);
        return item.date.month == lastMonth.month && item.date.year == lastMonth.year;
      } else {
        return item.date.year == now.year;
      }
    }).toList();

    double totalExpense = expenseTransactions.fold(0, (sum, item) => sum + item.amount);

    final Map<String, double> categoryTotals = {};
    for (var item in expenseTransactions) {
      categoryTotals[item.category] = (categoryTotals[item.category] ?? 0) + item.amount;
    }

    final colors = [
      Colors.redAccent,
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.indigo,
      Colors.teal,
      Colors.green,
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thống kê', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTimeTab(0, 'Tháng này'),
                    _buildTimeTab(1, 'Tháng trước'),
                    _buildTimeTab(2, 'Năm nay'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: DonutChartPainter(
                          categoryTotals: categoryTotals,
                          totalExpense: totalExpense,
                          colors: colors,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${formatCurrency(totalExpense)} đ',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text('Tổng chi tiêu', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Chi tiêu theo danh mục',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              categoryTotals.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Chưa có dữ liệu chi tiêu'),
                ),
              )
                  : Column(
                children: categoryTotals.entries.toList().asMap().entries.map((mapEntry) {
                  int idx = mapEntry.key;
                  var entry = mapEntry.value;
                  double percentage = totalExpense > 0 ? (entry.value / totalExpense) * 100 : 0;
                  Color dotColor = colors[idx % colors.length];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        Text(
                          '${formatCurrency(entry.value)} đ',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 45,
                          child: Text(
                            '${percentage.toStringAsFixed(0)}%',
                            textAlign: TextAlign.end,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTab(int index, String label) {
    final isSelected = _selectedTimeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTimeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final Map<String, double> categoryTotals;
  final double totalExpense;
  final List<Color> colors;

  DonutChartPainter({
    required this.categoryTotals,
    required this.totalExpense,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24.0;

    if (totalExpense == 0 || categoryTotals.isEmpty) {
      paint.color = Colors.grey.shade300;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    double startAngle = -pi / 2;
    int index = 0;

    categoryTotals.forEach((category, amount) {
      double sweepAngle = (amount / totalExpense) * 2 * pi;
      paint.color = colors[index % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
      index++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}