import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'profile_sub_screens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'Nguyễn Văn A';
  String userEmail = 'nguyenvana@example.com';
  double monthlyBudget = 5000000;

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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, size: 36, color: Color(0xFF1E88E5)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Thông tin cá nhân',
              onTap: () async {
                final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserInfoScreen(
                    currentName: userName,
                    currentEmail: userEmail,
                  ),
                ),
                );
                if (result != null) {
                  setState(() {
                    userName = result['name']!;
                    userEmail = result['email']!;
                  });
                }
              },
            ),

            _buildMenuItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Cài đặt ngân sách',
              onTap: () async {
                final newBudget = await Navigator.push<double>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BudgetSettingScreen(currentBudget: monthlyBudget),
                  ),
                );
                if (newBudget != null) {
                  setState(() => monthlyBudget = newBudget);
                }
              },
            ),

            _buildMenuItem(
              icon: Icons.format_list_bulleted,
              title: 'Danh mục chi tiêu',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryManagementScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.cloud_upload_outlined,
              title: 'Sao lưu dữ liệu',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BackupScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.lock_outline,
              title: 'Đổi mật khẩu',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.logout,
              title: 'Đăng xuất',
              textColor: Colors.red,
              iconColor: Colors.red,
              showChevron: false,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xác nhận đăng xuất'),
                    content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                          );
                        },
                        child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
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