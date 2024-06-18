import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../VideoRecorder/video_file_model.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  late Database _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'audio.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  void _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE audio_files(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE video_files(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT,
        dateTime TEXT
      )
    ''');
  }

  Future<void> insertAudioFile(String path) async {
    final db = await database;
    print('Inserting audio file at path: $path');
    await db.insert(
      'audio_files',
      {'path': path},
    );
  }

  Future<List<Map<String, dynamic>>> getAudioFiles() async {
    final db = await database;
    return await db.query('audio_files');
  }


  Future<void> insertVideoFile(VideoFile videoFile) async {
    final db = await database;
    print('Inserting video file at path: ${videoFile.path}');
    await db.insert(
        'video_files',
        videoFile.toMap()
    );
  }

  Future<List<VideoFile>> getVideoFiles() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('video_files');
    return List.generate(maps.length, (index) {
      return VideoFile(
          path: maps[index]['path'],
          dateTime: maps[index]['dateTime']
      );
    });
  }
}
