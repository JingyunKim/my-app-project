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

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'monthly_focus.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // 목표 테이블 생성
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month TEXT NOT NULL,
        position INTEGER NOT NULL,
        title TEXT NOT NULL,
        emoji TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 체크 테이블 생성
    await db.execute('''
      CREATE TABLE daily_checks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        checked_at TEXT NOT NULL,
        FOREIGN KEY (goal_id) REFERENCES goals (id)
      )
    ''');

    // 인덱스 생성
    await db.execute('CREATE INDEX idx_goals_month ON goals(month)');
    await db.execute('CREATE INDEX idx_daily_checks_date ON daily_checks(date)');
    await db.execute('CREATE INDEX idx_daily_checks_goal_id ON daily_checks(goal_id)');
  }

  // 목표 관련 메서드
  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    return await db.insert('goals', goal.toMap());
  }

  Future<List<Goal>> getGoalsByMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'month BETWEEN ? AND ?',
      whereArgs: [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
      orderBy: 'position ASC', // 목표 순서대로 정렬
    );
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  // 체크 관련 메서드
  Future<int> insertDailyCheck(DailyCheck check) async {
    final db = await database;
    return await db.insert('daily_checks', check.toMap());
  }

  Future<List<DailyCheck>> getDailyChecksByDate(DateTime date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_checks',
      where: 'date = ?',
      whereArgs: [date.toIso8601String()],
    );
    return List.generate(maps.length, (i) => DailyCheck.fromMap(maps[i]));
  }

  Future<void> updateDailyCheck(DailyCheck check) async {
    final db = await database;
    await db.update(
      'daily_checks',
      check.toMap(),
      where: 'id = ?',
      whereArgs: [check.id],
    );
  }

  // 데이터베이스 초기화
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('daily_checks');
    await db.delete('goals');
  }
} 