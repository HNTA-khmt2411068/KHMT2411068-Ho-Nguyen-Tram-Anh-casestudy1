import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'screens/transaction_form_screen.dart';

String formatCurrency(double amount) {
  return amount.toInt().toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
  );
}

Widget buildTransactionWidget(
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
    case 'Học bổng':
      icon = Icons.school;
      iconColor = Colors.teal;
      break;
    case 'Lì xì':
      icon = Icons.card_giftcard;
      iconColor = Colors.red;
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