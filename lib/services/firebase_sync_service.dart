import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/player_stats.dart';

class FirebaseSyncService {
  // Use getters to avoid immediate initialization
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  // Check if Firebase is available
  bool get isAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  String? get userId {
    if (!isAvailable) return null;
    return _auth.currentUser?.uid;
  }

  bool get isLoggedIn {
    if (!isAvailable) return false;
    return _auth.currentUser != null;
  }

  // Anonymous sign in for basic sync
  Future<void> signInAnonymously() async {
    if (!isAvailable) return;
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  Future<void> signOut() async {
    if (!isAvailable) return;
    await _auth.signOut();
  }

  // Get user's collection reference
  CollectionReference _getUserCollection(String collection) {
    if (!isAvailable) throw Exception('Firebase not initialized');
    if (userId == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(userId).collection(collection);
  }

  // Team sync
  Future<void> syncTeamToCloud(Team team) async {
    if (!isAvailable) return;
    try {
      await signInAnonymously();
      await _getUserCollection('teams').doc(team.id).set(team.toMap());
    } catch (e) {
      print('Sync error: $e');
    }
  }

  Future<List<Team>> getTeamsFromCloud() async {
    if (!isAvailable) return [];
    try {
      await signInAnonymously();
      final snapshot = await _getUserCollection('teams').get();
      return snapshot.docs.map((doc) => Team.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Sync error: $e');
      return [];
    }
  }

  Future<void> deleteTeamFromCloud(String teamId) async {
    if (!isAvailable) return;
    try {
      await signInAnonymously();
      await _getUserCollection('teams').doc(teamId).delete();
    } catch (e) {
      print('Sync error: $e');
    }
  }

  // Player sync
  Future<void> syncPlayerToCloud(Player player) async {
    if (!isAvailable) return;
    try {
      await signInAnonymously();
      await _getUserCollection('players').doc(player.id).set(player.toMap());
    } catch (e) {
      print('Sync error: $e');
    }
  }

  Future<List<Player>> getPlayersFromCloud() async {
    if (!isAvailable) return [];
    try {
      await signInAnonymously();
      final snapshot = await _getUserCollection('players').get();
      return snapshot.docs.map((doc) => Player.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Sync error: $e');
      return [];
    }
  }

  Future<void> deletePlayerFromCloud(String playerId) async {
    if (!isAvailable) return;
    try {
      await signInAnonymously();
      await _getUserCollection('players').doc(playerId).delete();
    } catch (e) {
      print('Sync error: $e');
    }
  }

  // Game sync
  Future<void> syncGameToCloud(Game game) async {
    if (!isAvailable) return;
    try {
      await signInAnonymously();
      await _getUserCollection('games').doc(game.id).set(game.toMap());
    } catch (e) {
      print('Sync error: $e');
    }
  }

  Future<List<Game>> getGamesFromCloud() async {
    if (!isAvailable) return [];
    try {
      await signInAnonymously();
      final snapshot = await _getUserCollection('games').get();
      return snapshot.docs.map((doc) => Game.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Sync error: $e');
      return [];
    }
  }

  Future<void> deleteGameFromCloud(String gameId) async {
    if (!isAvailable) return;
    try {
      await signInAnonymously();
      await _getUserCollection('games').doc(gameId).delete();
    } catch (e) {
      print('Sync error: $e');
    }
  }

  // Player stats sync
  Future<void> syncPlayerStatsToCloud(PlayerStats stats) async {
    if (!isAvailable) return;
    try {
      await signInAnonymously();
      await _getUserCollection('player_stats').doc(stats.id).set(stats.toMap());
    } catch (e) {
      print('Sync error: $e');
    }
  }

  Future<List<PlayerStats>> getPlayerStatsFromCloud() async {
    if (!isAvailable) return [];
    try {
      await signInAnonymously();
      final snapshot = await _getUserCollection('player_stats').get();
      return snapshot.docs.map((doc) => PlayerStats.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Sync error: $e');
      return [];
    }
  }

  Future<void> deletePlayerStatsFromCloud(String statsId) async {
    if (!isAvailable) return;
    try {
      await signInAnonymously();
      await _getUserCollection('player_stats').doc(statsId).delete();
    } catch (e) {
      print('Sync error: $e');
    }
  }

  // Full sync - push all local data to cloud
  Future<void> pushAllToCloud({
    required List<Team> teams,
    required List<Player> players,
    required List<Game> games,
    required List<PlayerStats> stats,
  }) async {
    if (!isAvailable) return;
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
    if (!isAvailable) return {
      'teams': [],
      'players': [],
      'games': [],
      'stats': [],
    };
    
    await signInAnonymously();
    
    return {
      'teams': await getTeamsFromCloud(),
      'players': await getPlayersFromCloud(),
      'games': await getGamesFromCloud(),
      'stats': await getPlayerStatsFromCloud(),
    };
  }
}
