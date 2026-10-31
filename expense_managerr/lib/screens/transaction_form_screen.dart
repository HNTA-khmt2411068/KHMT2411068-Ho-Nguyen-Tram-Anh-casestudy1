import 'package:flutter/material.dart';
import '../database_helper.dart';

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

  final List expenseCategories = [
  {'name': 'Ăn uống', 'icon': Icons.restaurant, 'color': Colors.redAccent},
  {'name': 'Mua sắm', 'icon': Icons.shopping_bag, 'color': Colors.blue},
  {'name': 'Đi lại', 'icon': Icons.directions_car, 'color': Colors.purple},
  {'name': 'Học tập', 'icon': Icons.menu_book, 'color': Colors.indigo},
  {'name': 'Khác', 'icon': Icons.more_horiz, 'color': Colors.orange},
  ];

  final List incomeCategories = [
  {'name': 'Lương', 'icon': Icons.account_balance_wallet, 'color': Colors.green},
  {'name': 'Học bổng', 'icon': Icons.school, 'color': Colors.teal},
  {'name': 'Lì xì', 'icon': Icons.card_giftcard, 'color': Colors.red},
  {'name': 'Khác', 'icon': Icons.more_horiz, 'color': Colors.orange},
  ];

  List get currentCategories =>
      isExpense ? expenseCategories : incomeCategories;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      isExpense = t.isExpense;
      final categoryExists = currentCategories.any((c) => c['name'] == t.category);
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

  void _switchType(bool expense) {
    setState(() {
      isExpense = expense;
      final exists = currentCategories.any((c) => c['name'] == selectedCategory);
      if (!exists) {
        selectedCategory = currentCategories.first['name'];
      }
    });
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
                              onTap: () => _switchType(true),
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
                              onTap: () => _switchType(false),
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
                          items: currentCategories.map((cat) {
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