import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../utils.dart';
import 'transaction_form_screen.dart';
import 'filter_screen.dart';

class TransactionListScreen extends StatefulWidget {
  final List<TransactionModel> transactions;
  final Function(TransactionModel) onAdd;
  final Function(TransactionModel) onUpdate;
  final Function(String) onDelete;

  const TransactionListScreen({
    super.key,
    required this.transactions,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _searchQuery = '';
  Map<String, dynamic>? _filterData;

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = widget.transactions.where((t) {
      final query = _searchQuery.toLowerCase();
      final matchesQuery = t.category.toLowerCase().contains(query) ||
          t.note.toLowerCase().contains(query);
      if (!matchesQuery) return false;

      if (_filterData != null) {
        bool isAllTypes = _filterData!['isAllTypes'] ?? true;
        bool isIncome = _filterData!['isIncome'] ?? false;
        bool isExpense = _filterData!['isExpense'] ?? false;
        String category = _filterData!['category'] ?? 'Tất cả danh mục';
        String timeRange = _filterData!['timeRange'] ?? 'Tất cả';

        if (!isAllTypes) {
          if (isIncome && t.isExpense) return false;
          if (isExpense && !t.isExpense) return false;
        }

        if (category != 'Tất cả danh mục' && t.category != category) {
          return false;
        }

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final txDate = DateTime(t.date.year, t.date.month, t.date.day);

        if (timeRange == 'Hôm nay') {
          if (txDate != today) return false;
        } else if (timeRange == '7 ngày qua') {
          if (txDate.isBefore(today.subtract(const Duration(days: 7)))) return false;
        } else if (timeRange == 'Tháng này') {
          if (t.date.month != now.month || t.date.year != now.year) return false;
        }
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Giao dịch', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm giao dịch...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: _filterData != null ? Colors.blue.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.tune,
                      color: _filterData != null ? const Color(0xFF1E88E5) : Colors.grey,
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilterScreen(initialFilter: _filterData),
                      ),
                      );
                      if (result != null) {
                        setState(() {
                          _filterData = result;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredTransactions.isEmpty
                  ? const Center(child: Text('Không tìm thấy giao dịch nào'))
                  : ListView.builder(
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  return buildTransactionWidget(
                    context,
                    filteredTransactions[index],
                    widget.onUpdate,
                    widget.onDelete,
                  );
                },
              ),
            ),
          ],
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
            await widget.onAdd(result);
          }
        },
      ),
    );
  }
}