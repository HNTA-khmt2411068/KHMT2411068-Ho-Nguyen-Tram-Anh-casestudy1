import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  final Map<String, dynamic>? initialFilter;

  const FilterScreen({super.key, this.initialFilter});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late bool isAllTypes;
  late bool isIncome;
  late bool isExpense;
  late String selectedCategory;
  late String selectedTimeRange;

  final List<String> categories = [
    'Tất cả danh mục',
    'Ăn uống',
    'Mua sắm',
    'Đi lại',
    'Học tập',
    'Lương',
    'Học bổng',
    'Lì xì',
    'Khác',
  ];

  final List<String> timeRanges = [
    'Tất cả',
    'Hôm nay',
    '7 ngày qua',
    'Tháng này',
  ];

  @override
  void initState() {
    super.initState();
    final init = widget.initialFilter;
    isAllTypes = init?['isAllTypes'] ?? true;
    isIncome = init?['isIncome'] ?? false;
    isExpense = init?['isExpense'] ?? false;
    selectedCategory = init?['category'] ?? 'Tất cả danh mục';
    selectedTimeRange = init?['timeRange'] ?? 'Tất cả';
  }

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

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
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