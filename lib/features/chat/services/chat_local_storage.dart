import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chat_message_model.dart';

class ChatLocalStorage {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'chat_history.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            article_url TEXT NOT NULL,
            content TEXT NOT NULL,
            is_user INTEGER NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> saveMessage(
    String articleUrl,
    ChatMessageModel message,
  ) async {
    final db = await database;
    await db.insert('messages', message.toMap(articleUrl));
  }

  Future<List<ChatMessageModel>> getMessages(String articleUrl) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'article_url = ?',
      whereArgs: [articleUrl],
      orderBy: 'timestamp ASC',
    );
    return maps.map((m) => ChatMessageModel.fromMap(m)).toList();
  }

  Future<void> clearMessages(String articleUrl) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'article_url = ?',
      whereArgs: [articleUrl],
    );
  }
}