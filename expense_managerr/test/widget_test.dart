import 'package:flutter_test/flutter_test.dart';
import 'package:expense_managerr/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseManagerApp());
    expect(find.text('Expense Manager'), findsOneWidget);
  });
}