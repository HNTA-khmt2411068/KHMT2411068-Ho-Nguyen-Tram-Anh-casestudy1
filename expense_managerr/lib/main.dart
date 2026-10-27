import 'dart:math';
import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseManagerApp());
}

// ==========================================
// CHƯƠNG TRÌNH CHÍNH & UI
// ==========================================
class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
    );
  }
}

// 1. MÀN HÌNH CHÀO MỪNG
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildWalletIcon(),
                  const SizedBox(height: 32),
                  const Text(
                    'Expense Manager',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Quản lý chi tiêu cá nhân\nđơn giản và hiệu quả',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Bắt đầu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletIcon() {
    return SizedBox(
      width: 100,
      height: 80,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 50,
              height: 25,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Container(
            width: 100,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Align(
              alignment: const Alignment(0.7, 0),
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ĐIỀU HƯỚNG & QUẢN LÝ DỮ LIỆU
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

// 2. MÀN HÌNH DASHBOARD
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
                  return _buildTransactionWidget(context, item, onUpdate, onDelete);
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

Widget _buildTransactionWidget(
    BuildContext context,
    TransactionModel item,
    Function(TransactionModel) onUpdate,
    Function(String) onDelete,
    ) {
  IconData icon = Icons.more_horiz;
  Color iconColor = Colors.orange;

  switch (item.category) {
    case 'Ăn uống':
      icon = Icons.restaurant;
      iconColor = Colors.redAccent;
      break;
    case 'Mua sắm':
      icon = Icons.shopping_bag;
      iconColor = Colors.blue;
      break;
    case 'Đi lại':
      icon = Icons.directions_car;
      iconColor = Colors.purple;
      break;
    case 'Học tập':
      icon = Icons.menu_book;
      iconColor = Colors.indigo;
      break;
    case 'Lương':
      icon = Icons.account_balance_wallet;
      iconColor = Colors.green;
      break;
  }

  String dateStr =
      "${item.date.day.toString().padLeft(2, '0')}/${item.date.month.toString().padLeft(2, '0')}/${item.date.year}";

  return Dismissible(
    key: Key(item.id),
    direction: DismissDirection.endToStart,
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    onDismissed: (direction) {
      onDelete(item.id);
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(item.category, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Text(
          '${item.isExpense ? "-" : "+"}${formatCurrency(item.amount)} đ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: item.isExpense ? Colors.red : Colors.green,
          ),
        ),
        onTap: () async {
          final result = await Navigator.push<TransactionModel>(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionFormScreen(
                isEdit: true,
                transactionToEdit: item,
              ),
            ),
          );
          if (result != null) {
            await onUpdate(result);
          }
        },
      ),
    ),
  );
}

// 3. MÀN HÌNH DANH SÁCH GIAO DỊCH
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

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = widget.transactions.where((t) {
      final query = _searchQuery.toLowerCase();
      return t.category.toLowerCase().contains(query) ||
          t.note.toLowerCase().contains(query);
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.grey),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FilterScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredTransactions.isEmpty
                  ? const Center(child: Text('Danh sách trống'))
                  : ListView.builder(
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  return _buildTransactionWidget(
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

// 4 & 5. MÀN HÌNH THÊM / SỬA GIAO DỊCH
class TransactionFormScreen extends StatefulWidget {
  final bool isEdit;
  final TransactionModel? transactionToEdit;

  const TransactionFormScreen({
    super.key,
    this.isEdit = false,
    this.transactionToEdit,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  late bool isExpense;
  late String selectedCategory;
  late TextEditingController amountController;
  late TextEditingController noteController;
  late DateTime selectedDate;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Ăn uống', 'icon': Icons.restaurant, 'color': Colors.redAccent},
    {'name': 'Mua sắm', 'icon': Icons.shopping_bag, 'color': Colors.blue},
    {'name': 'Đi lại', 'icon': Icons.directions_car, 'color': Colors.purple},
    {'name': 'Học tập', 'icon': Icons.menu_book, 'color': Colors.indigo},
    {'name': 'Lương', 'icon': Icons.account_balance_wallet, 'color': Colors.green},
    {'name': 'Khác', 'icon': Icons.more_horiz, 'color': Colors.orange},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      isExpense = t.isExpense;
      final categoryExists = categories.any((c) => c['name'] == t.category);
      selectedCategory = categoryExists ? t.category : 'Khác';
      amountController = TextEditingController(
        text: t.amount % 1 == 0 ? t.amount.toInt().toString() : t.amount.toString(),
      );
      noteController = TextEditingController(text: t.note);
      selectedDate = t.date;
    } else {
      isExpense = true;
      selectedCategory = 'Ăn uống';
      amountController = TextEditingController();
      noteController = TextEditingController();
      selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() => selectedDate = picked);
    }
  }

  void _saveForm() {
    String rawAmount = amountController.text
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();

    if (rawAmount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double? parsedAmount = double.tryParse(rawAmount);

    if (parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số tiền nhập vào không hợp lệ!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = TransactionModel(
      id: widget.isEdit
          ? widget.transactionToEdit!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      category: selectedCategory,
      amount: parsedAmount,
      date: selectedDate,
      note: noteController.text,
      isExpense: isExpense,
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'Sửa giao dịch' : 'Thêm giao dịch',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isExpense = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isExpense ? const Color(0xFFFF5252) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Chi tiêu',
                                    style: TextStyle(
                                      color: isExpense ? Colors.white : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isExpense = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !isExpense ? const Color(0xFF4CAF50) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Thu nhập',
                                    style: TextStyle(
                                      color: !isExpense ? Colors.white : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          items: categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat['name'],
                              child: Row(
                                children: [
                                  Icon(cat['icon'], color: cat['color'], size: 20),
                                  const SizedBox(width: 10),
                                  Text(cat['name']),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedCategory = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('Số tiền', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Nhập số tiền (VD: 100000)',
                        suffixText: 'đ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('Ngày giao dịch', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Nhập ghi chú (tùy chọn)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Lưu',
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 6. MÀN HÌNH THỐNG KÊ
class StatisticsScreen extends StatelessWidget {
  final List<TransactionModel> transactions;

  const StatisticsScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final expenseTransactions = transactions.where((item) => item.isExpense).toList();
    double totalExpense = expenseTransactions.fold(0, (sum, item) => sum + item.amount);

    final Map<String, double> categoryTotals = {};
    for (var item in expenseTransactions) {
      categoryTotals[item.category] = (categoryTotals[item.category] ?? 0) + item.amount;
    }

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
              Center(
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: DonutChartPainter(),
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
                children: categoryTotals.entries.map((entry) {
                  double percentage = totalExpense > 0 ? (entry.value / totalExpense) * 100 : 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          '${formatCurrency(entry.value)} đ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                            fontSize: 15,
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
}

class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24.0;

    final List<double> sweepAngles = [2 * pi * 0.40, 2 * pi * 0.30, 2 * pi * 0.30];
    final List<Color> colors = [Colors.redAccent, Colors.orange, Colors.blue];

    double startAngle = -pi / 2;
    for (int i = 0; i < sweepAngles.length; i++) {
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngles[i],
        false,
        paint,
      );
      startAngle += sweepAngles[i];
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Cá nhân',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          children: [
            // Thông tin User
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, size: 40, color: Color(0xFF1E88E5)),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nguyễn Văn A',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'nguyenvana@example.com',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Danh sách tùy chọn
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Thông tin cá nhân',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Cài đặt ngân sách',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.format_list_bulleted,
              title: 'Danh mục chi tiêu',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.cloud_upload_outlined,
              title: 'Sao lưu dữ liệu',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.lock_outline,
              title: 'Đổi mật khẩu',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Đăng xuất',
              textColor: Colors.red,
              iconColor: Colors.red,
              showChevron: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color textColor = Colors.black87,
    Color iconColor = Colors.grey,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: showChevron
            ? const Icon(Icons.chevron_right, color: Colors.grey, size: 20)
            : null,
        onTap: onTap,
      ),
    );
  }
}

// 8. MÀN HÌNH BỘ LỌC
class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // 1. Loại giao dịch
  bool isAllTypes = true;
  bool isIncome = false;
  bool isExpense = false;

  // 2. Danh mục
  String selectedCategory = 'Tất cả danh mục';
  final List<String> categories = [
    'Tất cả danh mục',
    'Ăn uống',
    'Mua sắm',
    'Đi lại',
    'Học tập',
    'Lương',
    'Khác',
  ];

  // 3. Khoảng thời gian
  String selectedTimeRange = 'Hôm nay';
  final List<String> timeRanges = [
    'Hôm nay',
    '7 ngày qua',
    'Tháng này',
    'Tùy chọn',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Bộ lọc',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SECTION 1: Loại giao dịch ---
                    const Text(
                      'Loại giao dịch',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    _buildCheckboxTile(
                      title: 'Tất cả',
                      value: isAllTypes,
                      onChanged: (val) {
                        setState(() {
                          isAllTypes = val ?? false;
                          if (isAllTypes) {
                            isIncome = false;
                            isExpense = false;
                          }
                        });
                      },
                    ),
                    _buildCheckboxTile(
                      title: 'Thu nhập',
                      value: isIncome,
                      onChanged: (val) {
                        setState(() {
                          isIncome = val ?? false;
                          if (isIncome) isAllTypes = false;
                        });
                      },
                    ),
                    _buildCheckboxTile(
                      title: 'Chi tiêu',
                      value: isExpense,
                      onChanged: (val) {
                        setState(() {
                          isExpense = val ?? false;
                          if (isExpense) isAllTypes = false;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // --- SECTION 2: Danh mục ---
                    const Text(
                      'Danh mục',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          items: categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Text(cat, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectedCategory = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- SECTION 3: Khoảng thời gian ---
                    const Text(
                      'Khoảng thời gian',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: timeRanges.map((range) {
                        return RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(range, style: const TextStyle(fontSize: 14)),
                          value: range,
                          groupValue: selectedTimeRange,
                          activeColor: const Color(0xFF1E88E5),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectedTimeRange = val);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Nút Áp dụng ở cuối màn hình
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Trả về kết quả bộ lọc cho màn hình trước
                    Navigator.pop(context, {
                      'isAllTypes': isAllTypes,
                      'isIncome': isIncome,
                      'isExpense': isExpense,
                      'category': selectedCategory,
                      'timeRange': selectedTimeRange,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Áp dụng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF1E88E5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
String formatCurrency(double amount) {
  return amount.toInt().toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
  );
}