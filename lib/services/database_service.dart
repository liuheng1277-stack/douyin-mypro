import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/video_model.dart';
import '../models/download_task_model.dart';
import '../utils/constants.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE videos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        video_id TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        author_id TEXT NOT NULL,
        cover_url TEXT NOT NULL,
        video_url TEXT,
        local_path TEXT,
        file_size INTEGER,
        duration INTEGER,
        width INTEGER,
        height INTEGER,
        format TEXT,
        create_time INTEGER,
        sync_time INTEGER,
        download_status INTEGER DEFAULT 0,
        is_favorite INTEGER DEFAULT 1,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE downloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        video_id TEXT NOT NULL,
        url TEXT NOT NULL,
        local_path TEXT,
        status INTEGER DEFAULT 0,
        progress REAL DEFAULT 0,
        total_size INTEGER,
        downloaded_size INTEGER,
        error_msg TEXT,
        create_time INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 未来版本升级时处理
  }

  // ========== Video CRUD ==========
  static Future<int> insertVideo(VideoModel video) async {
    final db = await database;
    return db.insert('videos', video.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<VideoModel>> getAllVideos() async {
    final db = await database;
    final maps = await db.query('videos', orderBy: 'sync_time DESC');
    return maps.map((m) => VideoModel.fromMap(m)).toList();
  }

  static Future<List<VideoModel>> getDownloadedVideos() async {
    final db = await database;
    final maps = await db.query(
      'videos',
      where: 'download_status = ?',
      whereArgs: [2],
      orderBy: 'sync_time DESC',
    );
    return maps.map((m) => VideoModel.fromMap(m)).toList();
  }

  static Future<VideoModel?> getVideoById(String videoId) async {
    final db = await database;
    final maps = await db.query('videos', where: 'video_id = ?', whereArgs: [videoId]);
    if (maps.isEmpty) return null;
    return VideoModel.fromMap(maps.first);
  }

  static Future<int> updateVideo(VideoModel video) async {
    final db = await database;
    return db.update('videos', video.toMap(), where: 'id = ?', whereArgs: [video.id]);
  }

  static Future<int> updateVideoDownloadStatus(String videoId, int status, {String? localPath}) async {
    final db = await database;
    final map = <String, dynamic>{'download_status': status};
    if (localPath != null) map['local_path'] = localPath;
    return db.update('videos', map, where: 'video_id = ?', whereArgs: [videoId]);
  }

  static Future<int> deleteVideo(int id) async {
    final db = await database;
    return db.delete('videos', where: 'id = ?', whereArgs: [id]);
  }

  // ========== Download Task CRUD ==========
  static Future<int> insertDownloadTask(DownloadTaskModel task) async {
    final db = await database;
    return db.insert('downloads', task.toMap());
  }

  static Future<List<DownloadTaskModel>> getAllDownloadTasks() async {
    final db = await database;
    final maps = await db.query('downloads', orderBy: 'create_time DESC');
    return maps.map((m) => DownloadTaskModel.fromMap(m)).toList();
  }

  static Future<int> updateDownloadTask(DownloadTaskModel task) async {
    final db = await database;
    return db.update('downloads', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  static Future<int> deleteDownloadTask(int id) async {
    final db = await database;
    return db.delete('downloads', where: 'id = ?', whereArgs: [id]);
  }

  // ========== Settings CRUD ==========
  static Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  static Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
