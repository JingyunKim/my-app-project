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
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'month = ?',
      whereArgs: [month.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  // [테스트용] 2025년 7월 샘플 목표 추가
  Future<void> insertJuly2025SampleGoals() async {
    final db = await database;
    final july2025 = DateTime(2025, 7, 1);
    
    // 기존 데이터 삭제
    await db.delete(
      'goals',
      where: 'month = ?',
      whereArgs: [july2025.toIso8601String()],
    );

    // 샘플 목표 데이터
    final sampleGoals = [
      Goal(
        month: july2025,
        position: 1,
        title: '제주도 한달 살기 준비하기',
        emoji: '🌴',
      ),
      Goal(
        month: july2025,
        position: 2,
        title: '매일 바다 수영 30분',
        emoji: '🏊',
      ),
      Goal(
        month: july2025,
        position: 3,
        title: '로컬 맛집 20곳 탐방',
        emoji: '🍱',
      ),
      Goal(
        month: july2025,
        position: 4,
        title: '제주 사투리 마스터하기',
        emoji: '🗣️',
      ),
    ];

    // 목표 추가
    for (var goal in sampleGoals) {
      await insertGoal(goal);
    }
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
} 