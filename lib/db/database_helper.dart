import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sale.dart';
import '../models/account.dart';
import '../models/sale_transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sales.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        accountId INTEGER,
        totalAmount REAL NOT NULL,
        date TEXT NOT NULL,
        sortableDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        amount REAL NOT NULL
      )
    ''');
  }

  // ---------- TRANSACTION FUNCTIONS ----------
  Future<int> insertTransaction(SaleTransaction transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<SaleTransaction>> getCashTransactions() async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: ['cash'],
      orderBy: 'id DESC',
    );
    return result.map((map) => SaleTransaction.fromMap(map)).toList();
  }

  Future<List<SaleTransaction>> getAccountTransactions(int accountId) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'id DESC',
    );
    return result.map((map) => SaleTransaction.fromMap(map)).toList();
  }

  // ---------- SALE (PRODUCT LINE) FUNCTIONS ----------
  Future<int> insertSale(Sale sale) async {
    final db = await instance.database;
    return await db.insert('sales', sale.toMap());
  }

  Future<List<Sale>> getSalesForTransaction(int transactionId) async {
    final db = await instance.database;
    final result = await db.query(
      'sales',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
      orderBy: 'id ASC',
    );
    return result.map((map) => Sale.fromMap(map)).toList();
  }

  // ---------- ACCOUNT FUNCTIONS ----------
  Future<int> insertAccount(Account account) async {
    final db = await instance.database;
    return await db.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await instance.database;
    final result = await db.query('accounts', orderBy: 'name ASC');
    return result.map((map) => Account.fromMap(map)).toList();
  }

  Future<int> updateAccount(Account account) async {
    final db = await instance.database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<double> getAccountTotalDue(int accountId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''
      SELECT 
        (SELECT COALESCE(SUM(totalAmount), 0) FROM transactions WHERE accountId = ? AND type = 'account') -
        (SELECT COALESCE(SUM(totalAmount), 0) FROM transactions WHERE accountId = ? AND type = 'payment') as total
      ''',
      [accountId, accountId],
    );
    final total = result.first['total'];
    return total == null ? 0.0 : (total as num).toDouble();
  }

  Future<Map<int, double>> getAllAccountDues() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT accountId,
        SUM(CASE WHEN type = 'account' THEN totalAmount ELSE 0 END) -
        SUM(CASE WHEN type = 'payment' THEN totalAmount ELSE 0 END) AS due
      FROM transactions
      WHERE accountId IS NOT NULL
      GROUP BY accountId
    ''');

    final Map<int, double> dues = {};
    for (var row in result) {
      final id = row['accountId'] as int;
      final due = row['due'] == null ? 0.0 : (row['due'] as num).toDouble();
      dues[id] = due;
    }
    return dues;
  }

  Future<Map<String, double>> getSalesSummary(String datePattern) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''
      SELECT
        SUM(CASE WHEN type IN ('cash','account') THEN totalAmount ELSE 0 END) as totalSales,
        SUM(CASE WHEN type IN ('cash','payment') THEN totalAmount ELSE 0 END) as cashReceived,
        SUM(CASE WHEN type = 'account' THEN totalAmount ELSE 0 END) as creditSales
      FROM transactions
      WHERE sortableDate LIKE ?
    ''',
      [datePattern],
    );

    final row = result.first;
    double val(String key) =>
        row[key] == null ? 0.0 : (row[key] as num).toDouble();
    return {
      'totalSales': val('totalSales'),
      'cashReceived': val('cashReceived'),
      'creditSales': val('creditSales'),
    };
  }

  Future<int> updateTransaction(SaleTransaction transaction) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteSalesForTransaction(int transactionId) async {
    final db = await instance.database;
    return await db.delete(
      'sales',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );
  }
}
