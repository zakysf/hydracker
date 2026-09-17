import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'hydrotrack.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabel user / anggota
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            berat REAL,
            tinggi REAL,
            tanggalLahir TEXT
          )
        ''');

        // Tabel catatan konsumsi air (CRUD utama)
        await db.execute('''
          CREATE TABLE konsumsi(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            jenis TEXT NOT NULL,
            volume REAL NOT NULL,
            tanggal TEXT NOT NULL,
            waktu TEXT NOT NULL,
            FOREIGN KEY(userId) REFERENCES users(id)
          )
        ''');

        // Akun default supaya bisa langsung login untuk demo
        await db.insert('users', {
          'nama': 'Zaky',
          'username': 'admin',
          'password': 'admin123',
          'berat': 60,
          'tinggi': 170,
          'tanggalLahir': '2000-01-01',
        });
      },
    );
  }

  // ---------- USER / LOGIN ----------
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<int> registerUser(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('users', data);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<int> updateUser(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('users', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- KONSUMSI AIR (CRUD) ----------
  Future<int> tambahKonsumsi(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('konsumsi', data);
  }

  Future<List<Map<String, dynamic>>> getKonsumsiByUser(int userId) async {
    final db = await database;
    return await db.query(
      'konsumsi',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  Future<int> updateKonsumsi(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('konsumsi', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteKonsumsi(int id) async {
    final db = await database;
    return await db.delete('konsumsi', where: 'id = ?', whereArgs: [id]);
  }
}
