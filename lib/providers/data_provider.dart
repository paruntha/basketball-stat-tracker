import 'package:flutter/foundation.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/player_stats.dart';
import '../services/database_helper.dart';
import '../services/firebase_sync_service.dart';

class DataProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final FirebaseSyncService _firebase = FirebaseSyncService();

  List<Team> _teams = [];
  List<Player> _players = [];
  List<Game> _games = [];
  List<PlayerStats> _stats = [];

  bool _isLoading = false;
  bool _isSyncing = false;

  List<Team> get teams => _teams;
  List<Player> get players => _players;
  List<Game> get games => _games;
  List<PlayerStats> get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  bool get isCloudSyncEnabled => _firebase.isLoggedIn;

  Future<void> initialize() async {
    await loadAllData();
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    _teams = await _db.getAllTeams();
    _games = await _db.getAllGames();
    
    // Load all players
    _players = [];
    for (var team in _teams) {
      final teamPlayers = await _db.getPlayersByTeam(team.id);
      _players.addAll(teamPlayers);
    }

    // Load all stats
    _stats = [];
    for (var game in _games) {
      final gameStats = await _db.getStatsByGame(game.id);
      _stats.addAll(gameStats);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Team operations
  Future<void> addTeam(Team team) async {
    await _db.insertTeam(team);
    if (_firebase.isLoggedIn) {
      await _firebase.syncTeamToCloud(team);
    }
    await loadAllData();
  }

  Future<void> deleteTeam(String teamId) async {
    await _db.deleteTeam(teamId);
    if (_firebase.isLoggedIn) {
      await _firebase.deleteTeamFromCloud(teamId);
    }
    await loadAllData();
  }

  // Player operations
  Future<void> addPlayer(Player player) async {
    await _db.insertPlayer(player);
    if (_firebase.isLoggedIn) {
      await _firebase.syncPlayerToCloud(player);
    }
    await loadAllData();
  }

  Future<void> updatePlayer(Player player) async {
    await _db.updatePlayer(player);
    if (_firebase.isLoggedIn) {
      await _firebase.syncPlayerToCloud(player);
    }
    await loadAllData();
  }

  Future<void> deletePlayer(String playerId) async {
    await _db.deletePlayer(playerId);
    if (_firebase.isLoggedIn) {
      await _firebase.deletePlayerFromCloud(playerId);
    }
    await loadAllData();
  }

  List<Player> getPlayersByTeam(String teamId) {
    return _players.where((p) => p.teamId == teamId).toList();
  }

  // Game operations
  Future<void> addGame(Game game) async {
    await _db.insertGame(game);
    if (_firebase.isLoggedIn) {
      await _firebase.syncGameToCloud(game);
    }
    await loadAllData();
  }

  Future<void> updateGame(Game game) async {
    await _db.updateGame(game);
    if (_firebase.isLoggedIn) {
      await _firebase.syncGameToCloud(game);
    }
    await loadAllData();
  }

  Future<void> deleteGame(String gameId) async {
    await _db.deleteGame(gameId);
    if (_firebase.isLoggedIn) {
      await _firebase.deleteGameFromCloud(gameId);
    }
    await loadAllData();
  }

  // Stats operations
  Future<void> addOrUpdatePlayerStats(PlayerStats stats) async {
    final existing = await _db.getPlayerStatsForGame(stats.playerId, stats.gameId);
    
    if (existing != null) {
      await _db.updatePlayerStats(stats);
    } else {
      await _db.insertPlayerStats(stats);
    }
    
    if (_firebase.isLoggedIn) {
      await _firebase.syncPlayerStatsToCloud(stats);
    }
    
    await loadAllData();
  }

  List<PlayerStats> getStatsByPlayer(String playerId) {
    return _stats.where((s) => s.playerId == playerId).toList();
  }

  List<PlayerStats> getStatsByGame(String gameId) {
    return _stats.where((s) => s.gameId == gameId).toList();
  }

  // Cloud sync operations
  Future<void> enableCloudSync() async {
    _isSyncing = true;
    notifyListeners();

    try {
      await _firebase.signInAnonymously();
      await pushToCloud();
    } catch (e) {
      print('Cloud sync error: $e');
    }

    _isSyncing = false;
    notifyListeners();
  }

  Future<void> pushToCloud() async {
    _isSyncing = true;
    notifyListeners();

    try {
      await _firebase.pushAllToCloud(
        teams: _teams,
        players: _players,
        games: _games,
        stats: _stats,
      );
    } catch (e) {
      print('Push to cloud error: $e');
    }

    _isSyncing = false;
    notifyListeners();
  }

  Future<void> pullFromCloud() async {
    _isSyncing = true;
    notifyListeners();

    try {
      final data = await _firebase.pullAllFromCloud();
      
      // Save to local database
      for (var team in data['teams'] as List<Team>) {
        await _db.insertTeam(team);
      }
      for (var player in data['players'] as List<Player>) {
        await _db.insertPlayer(player);
      }
      for (var game in data['games'] as List<Game>) {
        await _db.insertGame(game);
      }
      for (var stat in data['stats'] as List<PlayerStats>) {
        await _db.insertPlayerStats(stat);
      }
      
      await loadAllData();
    } catch (e) {
      print('Pull from cloud error: $e');
    }

    _isSyncing = false;
    notifyListeners();
  }

  Future<void> disableCloudSync() async {
    await _firebase.signOut();
    notifyListeners();
  }
}
