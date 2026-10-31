import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../utils.dart';
import 'transaction_form_screen.dart';

class DashboardScreen extends StatelessWidget {
  final List<TransactionModel> transactions;
  final Function(TransactionModel) onAdd;
  final Function(TransactionModel) onUpdate;
  final Function(String) onDelete;

  const DashboardScreen({
    super.key,
    required this.transactions,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    double totalIncome = transactions
        .where((item) => !item.isExpense)
        .fold(0, (sum, item) => sum + item.amount);

    double totalExpense = transactions
        .where((item) => item.isExpense)
        .fold(0, (sum, item) => sum + item.amount);

    double balance = totalIncome - totalExpense;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Hôm nay là một ngày tốt lành!',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Color(0xFF1E88E5),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Số dư hiện tại', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text(
                      '${formatCurrency(balance)} đ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Thu nhập',
                      '${formatCurrency(totalIncome)} đ',
                      Icons.arrow_upward,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Chi tiêu',
                      '${formatCurrency(totalExpense)} đ',
                      Icons.arrow_downward,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Chi tiêu gần đây',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              transactions.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Chưa có giao dịch nào trong CSDL'),
                ),
              )
                  : Column(
                children: transactions.take(5).map((item) {
                  return buildTransactionWidget(context, item, onUpdate, onDelete);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E88E5),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push<TransactionModel>(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionFormScreen(isEdit: false),
            ),
          );
          if (result != null) {
            await onAdd(result);
          }
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}