import "package:path/path.dart" as p;
import 'package:sqflite/sqflite.dart';

class TransactionModel {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String note;
  final bool isExpense;

  TransactionModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.note,
    required this.isExpense,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'isExpense': isExpense ? 1 : 0,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      note: map['note'] ?? '',
      isExpense: map['isExpense'] == 1,
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final bool isExpense;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.isExpense,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'isExpense': isExpense ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      icon: map['icon'] ?? '',
      isExpense: map['isExpense'] == 1,
    );
  }
}

class CategoryStatModel {
  final String category;
  final double totalAmount;

  CategoryStatModel({
    required this.category,
    required this.totalAmount,
  });

  factory CategoryStatModel.fromMap(Map<String, dynamic> map) {
    return CategoryStatModel(
      category: map['category'] ?? 'Khác',
      totalAmount: (map['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quanlychitieu.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        isExpense INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT,
        isExpense INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        monthYear TEXT NOT NULL
      )
    ''');

    await _insertDefaultCategories(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS categories (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          icon TEXT,
          isExpense INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS budgets (
          id TEXT PRIMARY KEY,
          amount REAL NOT NULL,
          monthYear TEXT NOT NULL
        )
      ''');
      await _insertDefaultCategories(db);
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {'id': 'cat_1', 'name': 'Ăn uống', 'icon': 'fastfood', 'isExpense': 1},
      {'id': 'cat_2', 'name': 'Di chuyển', 'icon': 'directions_car', 'isExpense': 1},
      {'id': 'cat_3', 'name': 'Mua sắm', 'icon': 'shopping_bag', 'isExpense': 1},
      {'id': 'cat_4', 'name': 'Lương', 'icon': 'attach_money', 'isExpense': 0},
    ];

    for (var cat in defaultCategories) {
      await db.insert('categories', cat, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<int> insertTransaction(TransactionModel item) async {
    final db = await instance.database;
    return await db.insert(
      'transactions',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<int> updateTransaction(TransactionModel item) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CategoryModel>> getCategories({bool? isExpense}) async {
    final db = await instance.database;
    final List result;
    if (isExpense != null) {
    result = await db.query(
    'categories',
    where: 'isExpense = ?',
    whereArgs: [isExpense ? 1 : 0],
    );
    } else {
    result = await db.query('categories');
    }
    return result.map((json) => CategoryModel.fromMap(json)).toList();
  }

  Future<int> insertCategory(CategoryModel item) async {
    final db = await instance.database;
    return await db.insert('categories', item.toMap());
  }

  Future<double> getTotalAmount({required bool isExpense}) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE isExpense = ?',
      [isExpense ? 1 : 0],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<List<CategoryStatModel>> getExpenseByCategory() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total 
      FROM transactions 
      WHERE isExpense = 1 
      GROUP BY category 
      ORDER BY total DESC
    ''');
    return result.map((json) => CategoryStatModel.fromMap(json)).toList();
  }

  Future<List<TransactionModel>> searchTransactions(String keyword) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'note LIKE ? OR category LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'date DESC',
    );
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }
}