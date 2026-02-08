import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/player_stats.dart';

class FirebaseSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;
  bool get isLoggedIn => _auth.currentUser != null;

  // Anonymous sign in for basic sync
  Future<void> signInAnonymously() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user's collection reference
  CollectionReference _getUserCollection(String collection) {
    if (userId == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(userId).collection(collection);
  }

  // Team sync
  Future<void> syncTeamToCloud(Team team) async {
    await signInAnonymously();
    await _getUserCollection('teams').doc(team.id).set(team.toMap());
  }

  Future<List<Team>> getTeamsFromCloud() async {
    await signInAnonymously();
    final snapshot = await _getUserCollection('teams').get();
    return snapshot.docs.map((doc) => Team.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> deleteTeamFromCloud(String teamId) async {
    await signInAnonymously();
    await _getUserCollection('teams').doc(teamId).delete();
  }

  // Player sync
  Future<void> syncPlayerToCloud(Player player) async {
    await signInAnonymously();
    await _getUserCollection('players').doc(player.id).set(player.toMap());
  }

  Future<List<Player>> getPlayersFromCloud() async {
    await signInAnonymously();
    final snapshot = await _getUserCollection('players').get();
    return snapshot.docs.map((doc) => Player.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> deletePlayerFromCloud(String playerId) async {
    await signInAnonymously();
    await _getUserCollection('players').doc(playerId).delete();
  }

  // Game sync
  Future<void> syncGameToCloud(Game game) async {
    await signInAnonymously();
    await _getUserCollection('games').doc(game.id).set(game.toMap());
  }

  Future<List<Game>> getGamesFromCloud() async {
    await signInAnonymously();
    final snapshot = await _getUserCollection('games').get();
    return snapshot.docs.map((doc) => Game.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> deleteGameFromCloud(String gameId) async {
    await signInAnonymously();
    await _getUserCollection('games').doc(gameId).delete();
  }

  // Player stats sync
  Future<void> syncPlayerStatsToCloud(PlayerStats stats) async {
    await signInAnonymously();
    await _getUserCollection('player_stats').doc(stats.id).set(stats.toMap());
  }

  Future<List<PlayerStats>> getPlayerStatsFromCloud() async {
    await signInAnonymously();
    final snapshot = await _getUserCollection('player_stats').get();
    return snapshot.docs.map((doc) => PlayerStats.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> deletePlayerStatsFromCloud(String statsId) async {
    await signInAnonymously();
    await _getUserCollection('player_stats').doc(statsId).delete();
  }

  // Full sync - push all local data to cloud
  Future<void> pushAllToCloud({
    required List<Team> teams,
    required List<Player> players,
    required List<Game> games,
    required List<PlayerStats> stats,
  }) async {
    await signInAnonymously();
    
    // Sync teams
    for (var team in teams) {
      await syncTeamToCloud(team);
    }
    
    // Sync players
    for (var player in players) {
      await syncPlayerToCloud(player);
    }
    
    // Sync games
    for (var game in games) {
      await syncGameToCloud(game);
    }
    
    // Sync stats
    for (var stat in stats) {
      await syncPlayerStatsToCloud(stat);
    }
  }

  // Full sync - pull all cloud data
  Future<Map<String, dynamic>> pullAllFromCloud() async {
    await signInAnonymously();
    
    return {
      'teams': await getTeamsFromCloud(),
      'players': await getPlayersFromCloud(),
      'games': await getGamesFromCloud(),
      'stats': await getPlayerStatsFromCloud(),
    };
  }
}
