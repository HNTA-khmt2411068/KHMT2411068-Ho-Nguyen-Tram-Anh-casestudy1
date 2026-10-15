import "dart:io";
import "package:flutter/services.dart";
import "package:path/path.dart" as p;
import 'package:sqflite/sqflite.dart';

// ==========================================
// 1. MODEL DỮ LIỆU GIAO DỊCH
// ==========================================
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

// ==========================================
// 2. LỚP XỬ LÝ DATABASE SQLITE
// ==========================================
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

    final exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(p.dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(p.join('assets', filePath));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(path);
  }

  Future<int> insertTransaction(TransactionModel item) async {
    final db = await instance.database;
    return await db.insert('transactions', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
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
}