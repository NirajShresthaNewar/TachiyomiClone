import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('manga_reader.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Manga table
    await db.execute('''
      CREATE TABLE manga (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        coverUrl TEXT,
        authors TEXT,
        genres TEXT,
        rating REAL,
        chapterCount INTEGER,
        status TEXT,
        isFavorite INTEGER DEFAULT 0,
        lastReadAt TEXT,
        createdAt TEXT
      )
    ''');

    // Chapters table
    await db.execute('''
      CREATE TABLE chapters (
        id TEXT PRIMARY KEY,
        mangaId TEXT NOT NULL,
        title TEXT NOT NULL,
        chapterNumber TEXT,
        volume TEXT,
        pageCount INTEGER,
        publishedAt TEXT,
        language TEXT,
        isRead INTEGER DEFAULT 0,
        lastReadPage INTEGER DEFAULT 0,
        FOREIGN KEY (mangaId) REFERENCES manga (id) ON DELETE CASCADE
      )
    ''');

    // Reading history table
    await db.execute('''
      CREATE TABLE reading_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mangaId TEXT NOT NULL,
        chapterId TEXT NOT NULL,
        lastReadPage INTEGER,
        timestamp TEXT,
        FOREIGN KEY (mangaId) REFERENCES manga (id) ON DELETE CASCADE,
        FOREIGN KEY (chapterId) REFERENCES chapters (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_manga_favorite ON manga(isFavorite)');
    await db.execute('CREATE INDEX idx_chapters_manga ON chapters(mangaId)');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}