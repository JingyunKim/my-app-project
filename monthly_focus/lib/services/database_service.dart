/*
 * DatabaseService: SQLite 데이터베이스 관리
 * 
 * 주요 기능:
 * - 목표(goals) 테이블 관리: 월간 목표 데이터 CRUD
 * - 체크(daily_checks) 테이블 관리: 일일 체크 데이터 CRUD
 * - 데이터베이스 초기화 및 마이그레이션
 * 
 * 테이블 구조:
 * - goals: id, month, position, title, emoji, created_at
 * - daily_checks: id, goal_id, date, is_completed, checked_at
 */

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/goal.dart';
import '../models/daily_check.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // 데이터베이스 인스턴스를 초기화하고 반환합니다.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // SQLite 데이터베이스를 생성하고 초기화합니다.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'monthly_focus.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  // 데이터베이스 테이블과 인덱스를 생성합니다.
  Future<void> _createTables(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          month TEXT NOT NULL,
          position INTEGER NOT NULL,
          title TEXT NOT NULL,
          emoji TEXT,
          created_at TEXT NOT NULL
        )
      ''');

      await txn.execute('''
        CREATE TABLE daily_checks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          goal_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          is_completed INTEGER NOT NULL DEFAULT 0,
          checked_at TEXT NOT NULL,
          FOREIGN KEY (goal_id) REFERENCES goals (id) ON DELETE CASCADE
        )
      ''');

      await txn.execute('CREATE INDEX idx_goals_month ON goals(month, position)');
      await txn.execute('CREATE INDEX idx_daily_checks_date_goal ON daily_checks(date, goal_id)');
      await txn.execute('CREATE INDEX idx_daily_checks_goal_date ON daily_checks(goal_id, date)');
    });
  }

  // 새로운 목표를 데이터베이스에 추가합니다.
  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.insert('goals', goal.toMap());
    });
  }

  // 특정 월의 목표 목록을 조회합니다.
  Future<List<Goal>> getGoalsByMonth(DateTime month) async {
    final db = await database;
    final monthStr = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: "substr(month, 1, 7) = ?",
      whereArgs: [monthStr],
      orderBy: 'position ASC',
    );
    
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  // 새로운 체크 데이터를 데이터베이스에 추가합니다.
  Future<int> insertDailyCheck(DailyCheck check) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.insert('daily_checks', check.toMap());
    });
  }

  // 특정 날짜의 체크 데이터를 조회합니다.
  Future<List<DailyCheck>> getDailyChecksByDate(DateTime date) async {
    final db = await database;
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT dc.* 
      FROM daily_checks dc
      WHERE date(dc.date) = date(?)
    ''', [dateStr]);
    
    return List.generate(maps.length, (i) => DailyCheck.fromMap(maps[i]));
  }

  // 체크 데이터를 업데이트합니다.
  Future<void> updateDailyCheck(DailyCheck check) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'daily_checks',
        check.toMap(),
        where: 'id = ?',
        whereArgs: [check.id],
      );
    });
  }

  // 모든 데이터를 초기화합니다.
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('daily_checks');
      await txn.delete('goals');
    });
  }

  // 지정된 날짜 이전의 오래된 데이터를 삭제합니다.
  Future<void> cleanupOldData(DateTime before) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'goals',
        where: 'month < ?',
        whereArgs: [before.toIso8601String()],
      );
    });
  }

  // 특정 월의 모든 체크 데이터를 한 번에 가져옵니다.
  Future<List<DailyCheck>> getDailyChecksByMonth(DateTime month) async {
    final db = await database;
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT dc.* 
      FROM daily_checks dc
      WHERE date(dc.date) >= date(?) AND date(dc.date) <= date(?)
      ORDER BY dc.date ASC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    return List.generate(maps.length, (i) => DailyCheck.fromMap(maps[i]));
  }
} 