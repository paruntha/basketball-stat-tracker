import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/data_provider.dart';
import '../services/export_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String? selectedPlayerId;
  final ExportService _exportService = ExportService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          if (selectedPlayerId != null)
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.file_download),
                      SizedBox(width: 8),
                      Text('Export CSV'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Share Summary'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'export') _exportPlayerStats();
                if (value == 'share') _shareSummary();
              },
            ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, child) {
          if (provider.players.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No player data yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
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
                    DropdownButtonFormField<String>(
                      value: selectedPlayerId,
                      hint: const Text('Choose a player'),
                      isExpanded: true,
                      items: provider.players.map((player) {
                        final team = provider.teams.firstWhere((t) => t.id == player.teamId);
                        return DropdownMenuItem(
                          value: player.id,
                          child: Text('${player.name} - ${team.name}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPlayerId = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Stats display
              Expanded(
                child: selectedPlayerId == null
                    ? const Center(child: Text('Select a player to view stats'))
                    : _buildPlayerStats(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayerStats(DataProvider provider) {
    final player = provider.players.firstWhere((p) => p.id == selectedPlayerId);
    final stats = provider.getStatsByPlayer(selectedPlayerId!);

    if (stats.isEmpty) {
      return const Center(
        child: Text('No game stats recorded for this player yet'),
      );
    }

    // Calculate averages
    final gamesPlayed = stats.length;
    final avgPoints = stats.map((s) => s.points).reduce((a, b) => a + b) / gamesPlayed;
    final avgRebounds = stats.map((s) => s.rebounds).reduce((a, b) => a + b) / gamesPlayed;
    final avgAssists = stats.map((s) => s.assists).reduce((a, b) => a + b) / gamesPlayed;

    final totalFGM = stats.map((s) => s.fieldGoalsMade).reduce((a, b) => a + b);
    final totalFGA = stats.map((s) => s.fieldGoalsAttempted).reduce((a, b) => a + b);
    final fgPct = totalFGA > 0 ? (totalFGM / totalFGA) * 100 : 0.0;

    final total3PM = stats.map((s) => s.threePointersMade).reduce((a, b) => a + b);
    final total3PA = stats.map((s) => s.threePointersAttempted).reduce((a, b) => a + b);
    final threePct = total3PA > 0 ? (total3PM / total3PA) * 100 : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      '#${player.jerseyNumber}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    player.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    player.position,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Season averages
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Season Averages',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Text('Games Played: $gamesPlayed'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatBox('PPG', avgPoints.toStringAsFixed(1)),
                      _buildStatBox('RPG', avgRebounds.toStringAsFixed(1)),
                      _buildStatBox('APG', avgAssists.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Shooting percentages
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shooting',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  _buildShootingRow('Field Goals', totalFGM, totalFGA, fgPct),
                  _buildShootingRow('3-Pointers', total3PM, total3PA, threePct),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Points trend chart
          if (stats.length > 1)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Points Per Game Trend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(value.toInt().toString());
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text('G${value.toInt() + 1}');
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: stats.asMap().entries.map((entry) {
                                return FlSpot(
                                  entry.key.toDouble(),
                                  entry.value.points.toDouble(),
                                );
                              }).toList(),
                              isCurved: true,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Game log
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Games',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  ...stats.take(5).map((stat) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'PTS: ${stat.points} | REB: ${stat.rebounds} | AST: ${stat.assists}',
                      ),
                      subtitle: Text(
                        'FG: ${stat.fieldGoalsMade}/${stat.fieldGoalsAttempted} | 3P: ${stat.threePointersMade}/${stat.threePointersAttempted}',
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildShootingRow(String label, int made, int attempted, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '$made/$attempted (${percentage.toStringAsFixed(1)}%)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPlayerStats() async {
    try {
      final provider = context.read<DataProvider>();
      final stats = provider.getStatsByPlayer(selectedPlayerId!);
      final players = {for (var p in provider.players) p.id: p};
      final games = {for (var g in provider.games) g.id: g};

      final filePath = await _exportService.exportPlayerStatsToCsv(stats, players, games);
      await _exportService.shareStatsCsv(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stats exported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _shareSummary() async {
    try {
      final provider = context.read<DataProvider>();
      final player = provider.players.firstWhere((p) => p.id == selectedPlayerId);
      final stats = provider.getStatsByPlayer(selectedPlayerId!);

      final summary = _exportService.generateSeasonSummary(stats, player);
      await _exportService.shareSummary(summary);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }
}
