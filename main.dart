import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: const ExpenseWelcomeScreen(),
    );
  }
}
class ExpenseWelcomeScreen extends StatelessWidget {
  const ExpenseWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              const CustomWalletIcon(),

              const SizedBox(height: 36),

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
                  color: Color(0xFF757575),
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E75D8),
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
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomWalletIcon extends StatelessWidget {
  const CustomWalletIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(110, 90),
      painter: WalletPainter(),
    );
  }
}

class WalletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    final greenPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final greenRect = RRect.fromLTRBR(
      size.width * 0.30,
      0,
      size.width * 0.70,
      size.height * 0.38,
      const Radius.circular(8),
    );
    canvas.drawRRect(greenRect, greenPaint);


    final bluePaint = Paint()
      ..color = const Color(0xFF1E75D8)
      ..style = PaintingStyle.fill;

    final blueRect = RRect.fromLTRBR(
      0,
      size.height * 0.22,
      size.width,
      size.height,
      const Radius.circular(16),
    );
    canvas.drawRRect(blueRect, bluePaint);


    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.61),
      6.0,
      whitePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}