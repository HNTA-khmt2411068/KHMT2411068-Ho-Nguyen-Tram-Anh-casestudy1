import 'package:flutter/material.dart';

// Nếu AddTransactionScreen đang nằm trong main.dart thì dùng:
// import 'main.dart';

// Nếu bạn tách AddTransactionScreen sang file khác thì sửa đường dẫn này.
import 'main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedBottomIndex = 0;

  final List<TransactionItem> transactions = [
    TransactionItem(
      title: 'Ăn trưa',
      category: 'Ăn uống',
      date: '03/09/2024',
      amount: '-50.000 đ',
      icon: Icons.restaurant,
      iconColor: const Color(0xFFFF7628),
      isIncome: false,
    ),
    TransactionItem(
      title: 'Xăng xe',
      category: 'Di chuyển',
      date: '03/09/2024',
      amount: '-100.000 đ',
      icon: Icons.directions_car,
      iconColor: const Color(0xFF1687F5),
      isIncome: false,
    ),
    TransactionItem(
      title: 'Lương tháng 9',
      category: 'Thu nhập',
      date: '01/09/2024',
      amount: '+8.000.000 đ',
      icon: Icons.attach_money,
      iconColor: const Color(0xFF25A849),
      isIncome: true,
    ),
    TransactionItem(
      title: 'Mua sắm',
      category: 'Mua sắm',
      date: '31/08/2024',
      amount: '-300.000 đ',
      icon: Icons.shopping_cart,
      iconColor: const Color(0xFF9747FF),
      isIncome: false,
    ),
    TransactionItem(
      title: 'Học phí',
      category: 'Giáo dục',
      date: '30/08/2024',
      amount: '-500.000 đ',
      icon: Icons.school,
      iconColor: const Color(0xFF009C9A),
      isIncome: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),

                    const SizedBox(height: 16),

                    _buildBalanceCard(),

                    const SizedBox(height: 12),

                    _buildIncomeExpense(),

                    const SizedBox(height: 18),

                    _buildRecentTitle(),

                    const SizedBox(height: 10),

                    _buildTransactionList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: _buildFloatingButton(),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.menu,
          size: 27,
          color: Color(0xFF1F2937),
        ),

        const SizedBox(width: 27),

        const Expanded(
          child: Text(
            'Quản lý thu chi',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172033),
            ),
          ),
        ),

        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_none_outlined,
              size: 28,
              color: Color(0xFF1F2937),
            ),

            Positioned(
              right: -3,
              top: -5,
              child: Container(
                width: 17,
                height: 17,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // BALANCE CARD
  // ============================================================

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      height: 152,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A82F4),
            Color(0xFF155DE4),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 29, 125, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'SỐ DƯ HIỆN TẠI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.visibility_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '5.000.000 đ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hình ví tiền dựng bằng icon
          Positioned(
            right: 22,
            top: 30,
            child: _buildWalletIllustration(),
          ),

          // Dấu trang ở dưới
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPageDot(true),
                _buildPageDot(false),
                _buildPageDot(false),
                _buildPageDot(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletIllustration() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 3,
            right: 8,
            child: Transform.rotate(
              angle: 0.18,
              child: Container(
                width: 45,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF72C987),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 23,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 8,
            left: 5,
            child: Container(
              width: 65,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF1B4E99),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF0C397B),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Color(0xFF5E91D9),
                size: 43,
              ),
            ),
          ),

          Positioned(
            bottom: 1,
            right: 4,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFFFB51B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.monetization_on,
                color: Color(0xFFFFD86A),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageDot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 13 : 6,
      height: 5,
      decoration: BoxDecoration(
        color: active
            ? Colors.white
            : Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  // ============================================================
  // INCOME / EXPENSE
  // ============================================================

  Widget _buildIncomeExpense() {
    return Row(
      children: [
        Expanded(
          child: _buildMoneySummary(
            title: 'TỔNG THU NHẬP',
            amount: '8.000.000 đ',
            icon: Icons.arrow_downward,
            iconColor: const Color(0xFF4CB963),
            backgroundColor: const Color(0xFFEAF8ED),
            amountColor: const Color(0xFF2CA044),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildMoneySummary(
            title: 'TỔNG CHI TIÊU',
            amount: '3.000.000 đ',
            icon: Icons.arrow_upward,
            iconColor: const Color(0xFFFF5964),
            backgroundColor: const Color(0xFFFFEFF1),
            amountColor: const Color(0xFFE83D49),
          ),
        ),
      ],
    );
  }

  Widget _buildMoneySummary({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color amountColor,
  }) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 23,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    amount,
                    style: TextStyle(
                      fontSize: 13,
                      color: amountColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT TRANSACTIONS TITLE
  // ============================================================

  Widget _buildRecentTitle() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Giao dịch gần đây',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ),

        GestureDetector(
          onTap: () {},
          child: const Text(
            'Xem tất cả',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF1769FF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TRANSACTION LIST
  // ============================================================

  Widget _buildTransactionList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE8EAF0),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < transactions.length; i++)
            _buildTransactionRow(
              transactions[i],
              isLast: i == transactions.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(
      TransactionItem item, {
        required bool isLast,
      }) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
          bottom: BorderSide(
            color: Color(0xFFE9EBF0),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF263043),
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF7B8494),
                      ),
                    ),

                    const SizedBox(width: 18),

                    Text(
                      item.date,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8A93A2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          Text(
            item.amount,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: item.isIncome
                  ? const Color(0xFF20A143)
                  : const Color(0xFFE83D49),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FLOATING BUTTON
  // ============================================================

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddTransactionScreen(),
          ),
        );
      },
      backgroundColor: const Color(0xFF1769FF),
      elevation: 5,
      shape: const CircleBorder(),
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 34,
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE8EAF0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomItem(
            index: 0,
            icon: Icons.home_rounded,
            label: 'Trang chủ',
          ),
          _buildBottomItem(
            index: 1,
            icon: Icons.receipt_long_outlined,
            label: 'Giao dịch',
          ),
          _buildBottomItem(
            index: 2,
            icon: Icons.pie_chart_outline,
            label: 'Thống kê',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool selected = selectedBottomIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBottomIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: selected
                  ? const Color(0xFF1769FF)
                  : const Color(0xFF273142),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? const Color(0xFF1769FF)
                    : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TRANSACTION DATA
// ============================================================

class TransactionItem {
  final String title;
  final String category;
  final String date;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final bool isIncome;

  const TransactionItem({
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.isIncome,
  });
}