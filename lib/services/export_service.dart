import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/player.dart';
import '../models/player_stats.dart';
import '../models/game.dart';

class ExportService {
  // Export player stats to CSV
  Future<String> exportPlayerStatsToCsv(
    List<PlayerStats> stats,
    Map<String, Player> players,
    Map<String, Game> games,
  ) async {
    List<List<dynamic>> rows = [];
    
    // Headers
    rows.add([
      'Date',
      'Player',
      'Opponent',
      'Points',
      'Rebounds',
      'Assists',
      'FG Made',
      'FG Attempted',
      'FG%',
      '3P Made',
      '3P Attempted',
      '3P%',
      'FT Made',
      'FT Attempted',
      'FT%',
      'Steals',
      'Blocks',
      'Turnovers',
      'Fouls',
      'Minutes',
    ]);

    // Data rows
    for (var stat in stats) {
      final player = players[stat.playerId];
      final game = games[stat.gameId];
      
      rows.add([
        game?.gameDate.toString().split(' ')[0] ?? '',
        player?.name ?? '',
        'vs Opponent', // You can enhance this with actual opponent info
        stat.points,
        stat.rebounds,
        stat.assists,
        stat.fieldGoalsMade,
        stat.fieldGoalsAttempted,
        stat.fieldGoalPercentage.toStringAsFixed(1),
        stat.threePointersMade,
        stat.threePointersAttempted,
        stat.threePointPercentage.toStringAsFixed(1),
        stat.freeThrowsMade,
        stat.freeThrowsAttempted,
        stat.freeThrowPercentage.toStringAsFixed(1),
        stat.steals,
        stat.blocks,
        stat.turnovers,
        stat.personalFouls,
        stat.minutesPlayed,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    
    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/basketball_stats_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    await file.writeAsString(csv);
    
    return path;
  }

  // Share CSV file
  Future<void> shareStatsCsv(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Basketball Stats Export',
      text: 'Here are the exported basketball statistics',
    );
  }

  // Generate season summary
  String generateSeasonSummary(
    List<PlayerStats> stats,
    Player player,
  ) {
    if (stats.isEmpty) return 'No stats available';

    int totalGames = stats.length;
    double avgPoints = stats.map((s) => s.points).reduce((a, b) => a + b) / totalGames;
    double avgRebounds = stats.map((s) => s.rebounds).reduce((a, b) => a + b) / totalGames;
    double avgAssists = stats.map((s) => s.assists).reduce((a, b) => a + b) / totalGames;
    
    int totalFGM = stats.map((s) => s.fieldGoalsMade).reduce((a, b) => a + b);
    int totalFGA = stats.map((s) => s.fieldGoalsAttempted).reduce((a, b) => a + b);
    double fgPct = totalFGA > 0 ? (totalFGM / totalFGA) * 100 : 0;
    
    int total3PM = stats.map((s) => s.threePointersMade).reduce((a, b) => a + b);
    int total3PA = stats.map((s) => s.threePointersAttempted).reduce((a, b) => a + b);
    double threePct = total3PA > 0 ? (total3PM / total3PA) * 100 : 0;

    return '''
SEASON SUMMARY - ${player.name} (#${player.jerseyNumber})

Games Played: $totalGames

Averages Per Game:
• Points: ${avgPoints.toStringAsFixed(1)}
• Rebounds: ${avgRebounds.toStringAsFixed(1)}
• Assists: ${avgAssists.toStringAsFixed(1)}

Shooting:
• FG%: ${fgPct.toStringAsFixed(1)}% ($totalFGM/$totalFGA)
• 3P%: ${threePct.toStringAsFixed(1)}% ($total3PM/$total3PA)

Total Stats:
• Points: ${stats.map((s) => s.points).reduce((a, b) => a + b)}
• Rebounds: ${stats.map((s) => s.rebounds).reduce((a, b) => a + b)}
• Assists: ${stats.map((s) => s.assists).reduce((a, b) => a + b)}
• Steals: ${stats.map((s) => s.steals).reduce((a, b) => a + b)}
• Blocks: ${stats.map((s) => s.blocks).reduce((a, b) => a + b)}
''';
  }

  // Share text summary
  Future<void> shareSummary(String summary) async {
    await Share.share(summary);
  }
}
