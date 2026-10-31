import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'dashboard_screen.dart';
import 'transaction_list_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  List<TransactionModel> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshTransactions();
  }

  Future<void> _refreshTransactions() async {
    setState(() => isLoading = true);
    try {
      final data = await DatabaseHelper.instance.getAllTransactions();
      if (!mounted) return;
      setState(() {
        transactions = data;
      });
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      if (!mounted) return;
      setState(() {
        transactions = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _addTransaction(TransactionModel item) async {
    await DatabaseHelper.instance.insertTransaction(item);
    await _refreshTransactions();
  }

  Future<void> _updateTransaction(TransactionModel item) async {
    await DatabaseHelper.instance.updateTransaction(item);
    await _refreshTransactions();
  }

  Future<void> _deleteTransaction(String id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await _refreshTransactions();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> screens = [
      DashboardScreen(
        transactions: transactions,
        onAdd: _addTransaction,
        onUpdate: _updateTransaction,
        onDelete: _deleteTransaction,
      ),
      TransactionListScreen(
        transactions: transactions,
        onAdd: _addTransaction,
        onUpdate: _updateTransaction,
        onDelete: _deleteTransaction,
      ),
      StatisticsScreen(transactions: transactions),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Giao dịch'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Thống kê'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}