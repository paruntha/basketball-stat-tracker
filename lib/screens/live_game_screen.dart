import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/data_provider.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/player_stats.dart';

class LiveGameScreen extends StatefulWidget {
  final Game game;

  const LiveGameScreen({super.key, required this.game});

  @override
  State<LiveGameScreen> createState() => _LiveGameScreenState();
}

class _LiveGameScreenState extends State<LiveGameScreen> {
  String? selectedPlayerId;
  late Game currentGame;
  Map<String, PlayerStats> gameStats = {};

  @override
  void initState() {
    super.initState();
    currentGame = widget.game;
    _loadGameStats();
  }

  Future<void> _loadGameStats() async {
    final provider = context.read<DataProvider>();
    final stats = provider.getStatsByGame(widget.game.id);
    
    setState(() {
      gameStats = {for (var stat in stats) stat.playerId: stat};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentGame.isComplete ? 'Game Summary' : 'Live Game'),
        actions: [
          if (!currentGame.isComplete)
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Finish Game',
              onPressed: _finishGame,
            ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, child) {
          final homeTeam = provider.teams.firstWhere((t) => t.id == currentGame.homeTeamId);
          final awayTeam = provider.teams.firstWhere((t) => t.id == currentGame.awayTeamId);
          final homePlayers = provider.getPlayersByTeam(homeTeam.id);
          final awayPlayers = provider.getPlayersByTeam(awayTeam.id);

          return Column(
            children: [
              // Scoreboard
              _buildScoreboard(homeTeam.name, awayTeam.name),

              // Player selector
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Player',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ..._buildPlayerChips(homePlayers, homeTeam.name),
                          const SizedBox(width: 8),
                          Container(
                            width: 2,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(width: 8),
                          ..._buildPlayerChips(awayPlayers, awayTeam.name),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Stat input panel
              if (selectedPlayerId != null && !currentGame.isComplete)
                Expanded(child: _buildStatInputPanel()),

              // Current stats display
              if (selectedPlayerId == null || currentGame.isComplete)
                Expanded(
                  child: _buildStatsTable(
                    [...homePlayers, ...awayPlayers],
                    provider,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScoreboard(String homeName, String awayName) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  homeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${currentGame.homeScore}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'VS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  awayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${currentGame.awayScore}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlayerChips(List<Player> players, String teamName) {
    return players.map((player) {
      final isSelected = selectedPlayerId == player.id;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text('#${player.jerseyNumber} ${player.name}'),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              selectedPlayerId = selected ? player.id : null;
            });
          },
        ),
      );
    }).toList();
  }

  Widget _buildStatInputPanel() {
    final stats = gameStats[selectedPlayerId!] ?? PlayerStats(
      id: const Uuid().v4(),
      gameId: currentGame.id,
      playerId: selectedPlayerId!,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQuickStatButtons(stats),
          const SizedBox(height: 24),
          _buildAdvancedStats(stats),
          const SizedBox(height: 24),
          _buildCurrentStatsSummary(stats),
        ],
      ),
    );
  }

  Widget _buildQuickStatButtons(PlayerStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatButton(
                  'Made 2PT',
                  () => _recordShot(stats, made: true, threePointer: false),
                  Colors.green,
                ),
                _buildStatButton(
                  'Missed 2PT',
                  () => _recordShot(stats, made: false, threePointer: false),
                  Colors.red,
                ),
                _buildStatButton(
                  'Made 3PT',
                  () => _recordShot(stats, made: true, threePointer: true),
                  Colors.blue,
                ),
                _buildStatButton(
                  'Missed 3PT',
                  () => _recordShot(stats, made: false, threePointer: true),
                  Colors.orange,
                ),
                _buildStatButton(
                  'Made FT',
                  () => _recordFreeThrow(stats, made: true),
                  Colors.purple,
                ),
                _buildStatButton(
                  'Missed FT',
                  () => _recordFreeThrow(stats, made: false),
                  Colors.deepPurple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatButton(
                  '+Rebound',
                  () => _incrementStat(stats, 'rebounds'),
                  Colors.brown,
                ),
                _buildStatButton(
                  '+Assist',
                  () => _incrementStat(stats, 'assists'),
                  Colors.teal,
                ),
                _buildStatButton(
                  '+Steal',
                  () => _incrementStat(stats, 'steals'),
                  Colors.cyan,
                ),
                _buildStatButton(
                  '+Block',
                  () => _incrementStat(stats, 'blocks'),
                  Colors.indigo,
                ),
                _buildStatButton(
                  '+Turnover',
                  () => _incrementStat(stats, 'turnovers'),
                  Colors.pink,
                ),
                _buildStatButton(
                  '+Foul',
                  () => _incrementStat(stats, 'fouls'),
                  Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }

  Widget _buildAdvancedStats(PlayerStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Minutes Played', stats.minutesPlayed, (val) {
              _updateStat(stats.copyWith(minutesPlayed: val));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
          ),
          Text('$value', style: const TextStyle(fontSize: 18)),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatsSummary(PlayerStats stats) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text('Points: ${stats.points}'),
            Text('Rebounds: ${stats.rebounds}'),
            Text('Assists: ${stats.assists}'),
            Text('FG: ${stats.fieldGoalsMade}/${stats.fieldGoalsAttempted} (${stats.fieldGoalPercentage.toStringAsFixed(1)}%)'),
            Text('3P: ${stats.threePointersMade}/${stats.threePointersAttempted} (${stats.threePointPercentage.toStringAsFixed(1)}%)'),
            Text('FT: ${stats.freeThrowsMade}/${stats.freeThrowsAttempted} (${stats.freeThrowPercentage.toStringAsFixed(1)}%)'),
            Text('Steals: ${stats.steals} | Blocks: ${stats.blocks}'),
            Text('Turnovers: ${stats.turnovers} | Fouls: ${stats.personalFouls}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTable(List<Player> players, DataProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Player')),
            DataColumn(label: Text('PTS')),
            DataColumn(label: Text('REB')),
            DataColumn(label: Text('AST')),
            DataColumn(label: Text('FG%')),
            DataColumn(label: Text('3P%')),
          ],
          rows: players.map((player) {
            final stats = gameStats[player.id];
            return DataRow(cells: [
              DataCell(Text('#${player.jerseyNumber} ${player.name}')),
              DataCell(Text('${stats?.points ?? 0}')),
              DataCell(Text('${stats?.rebounds ?? 0}')),
              DataCell(Text('${stats?.assists ?? 0}')),
              DataCell(Text(stats != null ? '${stats.fieldGoalPercentage.toStringAsFixed(1)}%' : '-')),
              DataCell(Text(stats != null ? '${stats.threePointPercentage.toStringAsFixed(1)}%' : '-')),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  void _recordShot(PlayerStats stats, {required bool made, required bool threePointer}) {
    final points = made ? (threePointer ? 3 : 2) : 0;
    final updatedStats = stats.copyWith(
      points: stats.points + points,
      fieldGoalsMade: stats.fieldGoalsMade + (made ? 1 : 0),
      fieldGoalsAttempted: stats.fieldGoalsAttempted + 1,
      threePointersMade: threePointer ? stats.threePointersMade + (made ? 1 : 0) : stats.threePointersMade,
      threePointersAttempted: threePointer ? stats.threePointersAttempted + 1 : stats.threePointersAttempted,
      updatedAt: DateTime.now(),
    );
    _updateStat(updatedStats);
    _updateScore(points);
  }

  void _recordFreeThrow(PlayerStats stats, {required bool made}) {
    final updatedStats = stats.copyWith(
      points: stats.points + (made ? 1 : 0),
      freeThrowsMade: stats.freeThrowsMade + (made ? 1 : 0),
      freeThrowsAttempted: stats.freeThrowsAttempted + 1,
      updatedAt: DateTime.now(),
    );
    _updateStat(updatedStats);
    if (made) _updateScore(1);
  }

  void _incrementStat(PlayerStats stats, String statName) {
    PlayerStats updatedStats;
    switch (statName) {
      case 'rebounds':
        updatedStats = stats.copyWith(rebounds: stats.rebounds + 1, updatedAt: DateTime.now());
        break;
      case 'assists':
        updatedStats = stats.copyWith(assists: stats.assists + 1, updatedAt: DateTime.now());
        break;
      case 'steals':
        updatedStats = stats.copyWith(steals: stats.steals + 1, updatedAt: DateTime.now());
        break;
      case 'blocks':
        updatedStats = stats.copyWith(blocks: stats.blocks + 1, updatedAt: DateTime.now());
        break;
      case 'turnovers':
        updatedStats = stats.copyWith(turnovers: stats.turnovers + 1, updatedAt: DateTime.now());
        break;
      case 'fouls':
        updatedStats = stats.copyWith(personalFouls: stats.personalFouls + 1, updatedAt: DateTime.now());
        break;
      default:
        return;
    }
    _updateStat(updatedStats);
  }

  void _updateStat(PlayerStats stats) {
    setState(() {
      gameStats[selectedPlayerId!] = stats;
    });
    context.read<DataProvider>().addOrUpdatePlayerStats(stats);
  }

  void _updateScore(int points) {
    final provider = context.read<DataProvider>();
    final player = provider.players.firstWhere((p) => p.id == selectedPlayerId);
    
    Game updatedGame;
    if (player.teamId == currentGame.homeTeamId) {
      updatedGame = currentGame.copyWith(homeScore: currentGame.homeScore + points);
    } else {
      updatedGame = currentGame.copyWith(awayScore: currentGame.awayScore + points);
    }
    
    setState(() {
      currentGame = updatedGame;
    });
    provider.updateGame(updatedGame);
  }

  void _finishGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Game'),
        content: const Text('Are you sure you want to mark this game as complete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final updatedGame = currentGame.copyWith(isComplete: true);
              context.read<DataProvider>().updateGame(updatedGame);
              setState(() {
                currentGame = updatedGame;
              });
              Navigator.pop(context);
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}
