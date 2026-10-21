import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/sale.dart';
import '../../models/account.dart';
import '../../models/sale_transaction.dart';

/// Database Helper managing SQLite operations for Saju Confectionery.
/// Supports atomic transactions for high financial data reliability.
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
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
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

    // Create indexes for fast querying over 10-15 years of records
    await db.execute('CREATE INDEX IF NOT EXISTS idx_trans_type ON transactions(type)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_trans_acc ON transactions(accountId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_trans_sortable ON transactions(sortableDate)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_sales_trans ON sales(transactionId)');
  }

  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add indexes if upgrading from version 1
      await db.execute('CREATE INDEX IF NOT EXISTS idx_trans_type ON transactions(type)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_trans_acc ON transactions(accountId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_trans_sortable ON transactions(sortableDate)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_sales_trans ON sales(transactionId)');
    }
  }

  // ==========================================
  // ATOMIC TRANSACTION & SALES OPERATIONS
  // ==========================================

  /// Atomically inserts a transaction and its associated item sales.
  Future<int> saveTransactionWithSales({
    required SaleTransaction transaction,
    required List<Sale> sales,
  }) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      final transactionId = await txn.insert('transactions', transaction.toMap());
      for (final sale in sales) {
        final item = Sale(
          transactionId: transactionId,
          productName: sale.productName,
          amount: sale.amount,
        );
        await txn.insert('sales', item.toMap());
      }
      return transactionId;
    });
  }

  /// Atomically updates a transaction and replaces its item sales.
  Future<void> updateTransactionWithSales({
    required SaleTransaction transaction,
    required List<Sale> sales,
  }) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.update(
        'transactions',
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );

      await txn.delete(
        'sales',
        where: 'transactionId = ?',
        whereArgs: [transaction.id],
      );

      for (final sale in sales) {
        final item = Sale(
          transactionId: transaction.id!,
          productName: sale.productName,
          amount: sale.amount,
        );
        await txn.insert('sales', item.toMap());
      }
    });
  }

  /// Atomically deletes a transaction and all its line items.
  Future<void> deleteTransaction(int transactionId) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete(
        'sales',
        where: 'transactionId = ?',
        whereArgs: [transactionId],
      );
      await txn.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [transactionId],
      );
    });
  }

  // ==========================================
  // TRANSACTION QUERY FUNCTIONS
  // ==========================================

  Future<int> insertTransaction(SaleTransaction transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
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

  // ==========================================
  // LINE ITEM (SALE) FUNCTIONS
  // ==========================================

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

  Future<int> deleteSalesForTransaction(int transactionId) async {
    final db = await instance.database;
    return await db.delete(
      'sales',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );
  }

  // ==========================================
  // ACCOUNT (CUSTOMER) FUNCTIONS
  // ==========================================

  Future<int> insertAccount(Account account) async {
    final db = await instance.database;
    return await db.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await instance.database;
    final result = await db.query('accounts', orderBy: 'name COLLATE NOCASE ASC');
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

  /// Deletes an account and all its transaction history.
  Future<void> deleteAccount(int accountId) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // Find all transaction ids for this account
      final transRows = await txn.query(
        'transactions',
        columns: ['id'],
        where: 'accountId = ?',
        whereArgs: [accountId],
      );
      for (final row in transRows) {
        final tId = row['id'] as int;
        await txn.delete('sales', where: 'transactionId = ?', whereArgs: [tId]);
      }
      await txn.delete('transactions', where: 'accountId = ?', whereArgs: [accountId]);
      await txn.delete('accounts', where: 'id = ?', whereArgs: [accountId]);
    });
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

  /// Fast aggregate calculation for all customer dues.
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

  /// Dashboard summary calculation for a specific day or month pattern.
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
}
