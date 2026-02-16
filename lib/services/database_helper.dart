import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/player_stats.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('basketball_stats.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // For web, we use the FFI web factory
      return databaseFactoryFfiWeb.openDatabase('basketball_stats.db',
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: _createDB,
          ));
    } else {
      // Mobile/Desktop implementation
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    // Teams table
    await db.execute('''
      CREATE TABLE teams (
        id $idType,
        name $textType,
        logo TEXT,
        created_at $textType
      )
    ''');

    // Players table
    await db.execute('''
      CREATE TABLE players (
        id $idType,
        name $textType,
        team_id $textType,        jersey_number $intType,
        position $textType,
        created_at $textType,
        FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE
      )
    ''');

    // Games table
    await db.execute('''
      CREATE TABLE games (
        id $idType,
        home_team_id $textType,
        away_team_id $textType,
        game_date $textType,
        location TEXT,
        is_complete $boolType,
        home_score $intType,
        away_score $intType,
        created_at $textType,
        FOREIGN KEY (home_team_id) REFERENCES teams (id),
        FOREIGN KEY (away_team_id) REFERENCES teams (id)
      )
    ''');

    // Player stats table
    await db.execute('''
      CREATE TABLE player_stats (
        id $idType,
        game_id $textType,
        player_id $textType,
        points $intType,
        rebounds $intType,
        assists $intType,
        field_goals_made $intType,
        field_goals_attempted $intType,
        three_pointers_made $intType,
        three_pointers_attempted $intType,
        free_throws_made $intType,
        free_throws_attempted $intType,
        steals $intType,
        blocks $intType,
        turnovers $intType,
        personal_fouls $intType,
        minutes_played $intType,
        created_at $textType,
        updated_at $textType,
        FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE,
        FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE
      )
    ''');
  }

  // Team CRUD operations
  Future<void> insertTeam(Team team) async {
    final db = await database;
    await db.insert('teams', team.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Team>> getAllTeams() async {
    final db = await database;
    final result = await db.query('teams', orderBy: 'name ASC');
    return result.map((map) => Team.fromMap(map)).toList();
  }

  Future<Team?> getTeam(String id) async {
    final db = await database;
    final maps = await db.query('teams', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Team.fromMap(maps.first);
  }

  Future<void> deleteTeam(String id) async {
    final db = await database;
    await db.delete('teams', where: 'id = ?', whereArgs: [id]);
  }

  // Player CRUD operations
  Future<void> insertPlayer(Player player) async {
    final db = await database;
    await db.insert('players', player.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Player>> getPlayersByTeam(String teamId) async {
    final db = await database;
    final result = await db.query('players', where: 'team_id = ?', whereArgs: [teamId], orderBy: 'jersey_number ASC');
    return result.map((map) => Player.fromMap(map)).toList();
  }

  Future<List<Player>> getAllPlayers() async {
    final db = await database;
    final result = await db.query('players', orderBy: 'name ASC');
    return result.map((map) => Player.fromMap(map)).toList();
  }

  Future<Player?> getPlayer(String id) async {
    final db = await database;
    final maps = await db.query('players', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Player.fromMap(maps.first);
  }

  Future<void> updatePlayer(Player player) async {
    final db = await database;
    await db.update('players', player.toMap(), where: 'id = ?', whereArgs: [player.id]);
  }

  Future<void> deletePlayer(String id) async {
    final db = await database;
    await db.delete('players', where: 'id = ?', whereArgs: [id]);
  }

  // Game CRUD operations
  Future<void> insertGame(Game game) async {
    final db = await database;
    await db.insert('games', game.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Game>> getAllGames() async {
    final db = await database;
    final result = await db.query('games', orderBy: 'game_date DESC');
    return result.map((map) => Game.fromMap(map)).toList();
  }

  Future<Game?> getGame(String id) async {
    final db = await database;
    final maps = await db.query('games', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Game.fromMap(maps.first);
  }

  Future<void> updateGame(Game game) async {
    final db = await database;
    await db.update('games', game.toMap(), where: 'id = ?', whereArgs: [game.id]);
  }

  Future<void> deleteGame(String id) async {
    final db = await database;
    await db.delete('games', where: 'id = ?', whereArgs: [id]);
  }

  // Player Stats CRUD operations
  Future<void> insertPlayerStats(PlayerStats stats) async {
    final db = await database;
    await db.insert('player_stats', stats.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PlayerStats>> getStatsByGame(String gameId) async {
    final db = await database;
    final result = await db.query('player_stats', where: 'game_id = ?', whereArgs: [gameId]);
    return result.map((map) => PlayerStats.fromMap(map)).toList();
  }

  Future<List<PlayerStats>> getStatsByPlayer(String playerId) async {
    final db = await database;
    final result = await db.query('player_stats', where: 'player_id = ?', whereArgs: [playerId], orderBy: 'created_at DESC');
    return result.map((map) => PlayerStats.fromMap(map)).toList();
  }

  Future<PlayerStats?> getPlayerStatsForGame(String playerId, String gameId) async {
    final db = await database;
    final maps = await db.query(
      'player_stats',
      where: 'player_id = ? AND game_id = ?',
      whereArgs: [playerId, gameId],
    );
    if (maps.isEmpty) return null;
    return PlayerStats.fromMap(maps.first);
  }

  Future<void> updatePlayerStats(PlayerStats stats) async {
    final db = await database;
    await db.update('player_stats', stats.toMap(), where: 'id = ?', whereArgs: [stats.id]);
  }

  Future<void> deletePlayerStats(String id) async {
    final db = await database;
    await db.delete('player_stats', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
