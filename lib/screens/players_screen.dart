import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../providers/data_provider.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final _uuid = const Uuid();

  void _showAddPlayerDialog() {
    final nameController = TextEditingController();
    final jerseyController = TextEditingController();
    String position = 'Guard'; // Default
    String? selectedTeamId;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Player'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Player Name'),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: jerseyController,
                decoration: const InputDecoration(labelText: 'Jersey Number'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: position,
                decoration: const InputDecoration(labelText: 'Position'),
                items: ['Guard', 'Forward', 'Center', 'Point Guard', 'Shooting Guard', 'Small Forward', 'Power Forward']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => position = value!,
              ),
              const SizedBox(height: 16),
              Consumer<DataProvider>(
                builder: (context, dataProvider, child) {
                  return DropdownButtonFormField<String?>(
                    value: selectedTeamId,
                    decoration: const InputDecoration(labelText: 'Team (Optional)'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Unassigned'),
                      ),
                      ...dataProvider.teams.map((team) => DropdownMenuItem(
                            value: team.id,
                            child: Text(team.name),
                          )),
                    ],
                    onChanged: (value) => selectedTeamId = value,
                  );
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
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || jerseyController.text.isEmpty) {
                return;
              }

              final player = Player(
                id: _uuid.v4(),
                name: nameController.text,
                teamId: selectedTeamId,
                jerseyNumber: int.parse(jerseyController.text),
                position: position,
                createdAt: DateTime.now(),
              );

              context.read<DataProvider>().addPlayer(player);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Players'),
        centerTitle: true,
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          if (dataProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final players = dataProvider.players; // We need to ensure DataProvider loads ALL players

          if (players.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No players yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddPlayerDialog,
                    child: const Text('Add Player'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              final teamName = player.teamId != null 
                  ? dataProvider.teams.firstWhere((t) => t.id == player.teamId, orElse: () => Team(id: '', name: 'Unknown', createdAt: DateTime.now())).name
                  : 'Unassigned';

              return ListTile(
                leading: CircleAvatar(
                  child: Text(player.jerseyNumber.toString()),
                ),
                title: Text(player.name),
                subtitle: Text('$teamName • ${player.position}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Implement edit player dialog
                    _showEditPlayerDialog(context, player);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlayerDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditPlayerDialog(BuildContext context, Player player) {
     final nameController = TextEditingController(text: player.name);
    final jerseyController = TextEditingController(text: player.jerseyNumber.toString());
    String position = player.position;
    String? selectedTeamId = player.teamId;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Player'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Player Name'),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: jerseyController,
                decoration: const InputDecoration(labelText: 'Jersey Number'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: position,
                 decoration: const InputDecoration(labelText: 'Position'),
                items: ['Guard', 'Forward', 'Center', 'Point Guard', 'Shooting Guard', 'Small Forward', 'Power Forward']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => position = value!,
              ),
              const SizedBox(height: 16),
              Consumer<DataProvider>(
                builder: (context, dataProvider, child) {
                  return DropdownButtonFormField<String?>(
                    value: selectedTeamId,
                    decoration: const InputDecoration(labelText: 'Team (Optional)'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Unassigned'),
                      ),
                      ...dataProvider.teams.map((team) => DropdownMenuItem(
                            value: team.id,
                            child: Text(team.name),
                          )),
                    ],
                    onChanged: (value) => selectedTeamId = value,
                  );
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
          TextButton(
             onPressed: () {
               // Confirm delete
               showDialog(context: context, builder: (context) => AlertDialog(
                 title: const Text('Delete Player'),
                 content: Text('Are you sure you want to delete ${player.name}? This cannot be undone.'),
                 actions: [
                   TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                   TextButton(onPressed: () {
                     context.read<DataProvider>().deletePlayer(player.id);
                     Navigator.pop(context); // Close confirm
                     Navigator.pop(context); // Close edit
                   }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
                 ],
               ));
             },
             child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || jerseyController.text.isEmpty) {
                return;
              }

              final updatedPlayer = player.copyWith(
                name: nameController.text,
                teamId: selectedTeamId,
                jerseyNumber: int.parse(jerseyController.text),
                position: position,
              );

              context.read<DataProvider>().updatePlayer(updatedPlayer);
              Navigator.pop(context);
            },
             child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
