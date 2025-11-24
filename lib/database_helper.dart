import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grade_project/demo_data.dart' as demo;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:grade_project/masareef_transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'money_tracker.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        date TEXT,
        category TEXT,
        type TEXT,
        notes TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN type TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE transactions ADD COLUMN notes TEXT');
    }
    if (oldVersion < 4) {
      // Recreate table without the color column
      await db.execute('CREATE TABLE transactions_new(id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL, date TEXT, category TEXT, type TEXT, notes TEXT)');
      await db.execute('INSERT INTO transactions_new(id, amount, date, category, type, notes) SELECT id, amount, date, category, type, notes FROM transactions');
      await db.execute('DROP TABLE transactions');
      await db.execute('ALTER TABLE transactions_new RENAME TO transactions');
    }
  }

  Future<int> insertTransaction(MasareefTransaction transaction) async {
    final db = await database;
    return await db.insert('transactions', {
      'amount': transaction.amount,
      'date': transaction.date.toIso8601String(),
      'category': transaction.category,
      'type': transaction.type,
      'notes': transaction.notes,
    });
  }

  Future<List<MasareefTransaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC');
    return List.generate(maps.length, (i) {
      return MasareefTransaction(
        id: maps[i]['id'],
        amount: maps[i]['amount'],
        date: DateTime.parse(maps[i]['date']),
        category: maps[i]['category'] ?? 'Other',
        type: maps[i]['type'] ?? 'expense',
        notes: maps[i]['notes'] ?? '',
      );
    });
  }

  Future<int> updateTransaction(MasareefTransaction transaction, int id) async {
    final db = await database;
    return await db.update(
      'transactions',
      {
        'amount': transaction.amount,
        'date': transaction.date.toIso8601String(),
        'category': transaction.category,
        'type': transaction.type,
        'notes': transaction.notes,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Deletes all records from the transactions table.
  Future<int> deleteAllTransactions() async {
    final db = await database;
    return await db.delete('transactions');
  }

  Future<void> insertDemoData() async {
    final db = await database;
    await demo.insertDemoData(db);
  }
}
