import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              const SizedBox(height: 16),
              
              // Cloud Sync Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Cloud Sync',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Cloud Sync'),
                      subtitle: Text(
                        provider.isCloudSyncEnabled
                            ? 'Your data is synced to the cloud'
                            : 'Sync your data across devices',
                      ),
                      value: provider.isCloudSyncEnabled,
                      onChanged: (value) async {
                        if (value) {
                          await provider.enableCloudSync();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cloud sync enabled!'),
                              ),
                            );
                          }
                        } else {
                          await provider.disableCloudSync();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cloud sync disabled'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    if (provider.isCloudSyncEnabled) ...[
                      const Divider(),
                      ListTile(
                        leading: provider.isSyncing
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.cloud_upload),
                        title: const Text('Push to Cloud'),
                        subtitle: const Text('Upload local data to cloud'),
                        enabled: !provider.isSyncing,
                        onTap: () async {
                          await provider.pushToCloud();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Data pushed to cloud!'),
                              ),
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: provider.isSyncing
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.cloud_download),
                        title: const Text('Pull from Cloud'),
                        subtitle: const Text('Download cloud data to device'),
                        enabled: !provider.isSyncing,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Pull from Cloud'),
                              content: const Text(
                                'This will merge cloud data with your local data. Continue?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Pull'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await provider.pullFromCloud();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Data pulled from cloud!'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Data Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Data',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Database Stats'),
                      subtitle: Text(
                        '${provider.teams.length} teams, ${provider.players.length} players, ${provider.games.length} games',
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.refresh),
                      title: const Text('Reload Data'),
                      subtitle: const Text('Refresh from local database'),
                      onTap: () async {
                        await provider.loadAllData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data reloaded!'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // About Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'About',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.sports_basketball),
                      title: Text('Basketball Stat Tracker'),
                      subtitle: Text('Version 1.0.0'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('Features'),
                      subtitle: const Text(
                        'Live game tracking, player stats, cloud sync, and export',
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Features'),
                            content: const SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('• Track multiple teams and players'),
                                  Text('• Live game stat tracking'),
                                  Text('• Basic stats: Points, Rebounds, Assists'),
                                  Text('• Advanced stats: FG%, 3P%, Steals, Blocks, Turnovers'),
                                  Text('• Historical stats and trends'),
                                  Text('• Player performance charts'),
                                  Text('• Export to CSV'),
                                  Text('• Share summaries'),
                                  Text('• Cloud sync (optional)'),
                                  Text('• Works offline'),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
