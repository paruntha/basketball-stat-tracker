import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/data_provider.dart';
import '../models/team.dart';
import '../models/player.dart';

class TeamDetailScreen extends StatelessWidget {
  final Team team;

  const TeamDetailScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDeleteTeam(context),
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, child) {
          final players = provider.getPlayersByTeam(team.id);

          return Column(
            children: [
              // Team header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        team.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      team.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${players.length} Players',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Players list
              Expanded(
                child: players.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_outline,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No players yet',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          final player = players[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('#${player.jerseyNumber}'),
                              ),
                              title: Text(
                                player.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(player.position),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    _confirmDeletePlayer(context, player),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPlayerDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Player'),
      ),
    );
  }

  void _showAddPlayerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final jerseyController = TextEditingController();
    String selectedPosition = 'Guard';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Player'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Player Name',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: jerseyController,
                  decoration: const InputDecoration(
                    labelText: 'Jersey Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedPosition,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Point Guard', 'Shooting Guard', 'Small Forward',
                          'Power Forward', 'Center', 'Guard', 'Forward']
                      .map((pos) => DropdownMenuItem(
                            value: pos,
                            child: Text(pos),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPosition = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty &&
                    jerseyController.text.trim().isNotEmpty) {
                  final player = Player(
                    id: const Uuid().v4(),
                    name: nameController.text.trim(),
                    teamId: team.id,
                    jerseyNumber: int.parse(jerseyController.text.trim()),
                    position: selectedPosition,
                    createdAt: DateTime.now(),
                  );
                  context.read<DataProvider>().addPlayer(player);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePlayer(BuildContext context, Player player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text('Are you sure you want to delete ${player.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<DataProvider>().deletePlayer(player.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTeam(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text(
            'Are you sure you want to delete ${team.name}? This will also delete all players and their stats.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<DataProvider>().deleteTeam(team.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
