import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:financial_management_app/models/transaction.dart' as fm;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  String transactionsTable = 'transaction_table';
  String colId = 'id';
  String colDescription = 'description';
  String colAmount = 'amount';
  String colDate = 'date';
  String colIsIncome = 'isIncome';

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String dir = await getDatabasesPath();
    String path = join(dir, 'transactions.db');
    final transactionsDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return transactionsDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $transactionsTable(
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colDescription TEXT,
        $colAmount REAL,
        $colDate TEXT,
        $colIsIncome INTEGER
      )
    ''');
  }

  Future<List<fm.Transaction>> getTransactions() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(transactionsTable);
    return result.map((map) => fm.Transaction.fromMap(map)).toList();
  }

  Future<int> insertTransaction(fm.Transaction transaction) async {
    Database db = await this.db;
    return await db.insert(transactionsTable, transaction.toMap());
  }

  Future<int> updateTransaction(fm.Transaction transaction) async {
    Database db = await this.db;
    return await db.update(transactionsTable, transaction.toMap(),
        where: '$colId = ?', whereArgs: [transaction.id]);
  }

  Future<int> deleteTransaction(int id) async {
    Database db = await this.db;
    return await db
        .delete(transactionsTable, where: '$colId = ?', whereArgs: [id]);
  }
}
