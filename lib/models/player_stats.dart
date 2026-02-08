class PlayerStats {
  final String id;
  final String gameId;
  final String playerId;
  
  // Basic Stats
  final int points;
  final int rebounds;
  final int assists;
  
  // Advanced Stats
  final int fieldGoalsMade;
  final int fieldGoalsAttempted;
  final int threePointersMade;
  final int threePointersAttempted;
  final int freeThrowsMade;
  final int freeThrowsAttempted;
  final int steals;
  final int blocks;
  final int turnovers;
  final int personalFouls;
  final int minutesPlayed;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  PlayerStats({
    required this.id,
    required this.gameId,
    required this.playerId,
    this.points = 0,
    this.rebounds = 0,
    this.assists = 0,
    this.fieldGoalsMade = 0,
    this.fieldGoalsAttempted = 0,
    this.threePointersMade = 0,
    this.threePointersAttempted = 0,
    this.freeThrowsMade = 0,
    this.freeThrowsAttempted = 0,
    this.steals = 0,
    this.blocks = 0,
    this.turnovers = 0,
    this.personalFouls = 0,
    this.minutesPlayed = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculated percentages
  double get fieldGoalPercentage {
    if (fieldGoalsAttempted == 0) return 0.0;
    return (fieldGoalsMade / fieldGoalsAttempted) * 100;
  }

  double get threePointPercentage {
    if (threePointersAttempted == 0) return 0.0;
    return (threePointersMade / threePointersAttempted) * 100;
  }

  double get freeThrowPercentage {
    if (freeThrowsAttempted == 0) return 0.0;
    return (freeThrowsMade / freeThrowsAttempted) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'game_id': gameId,
      'player_id': playerId,
      'points': points,
      'rebounds': rebounds,
      'assists': assists,
      'field_goals_made': fieldGoalsMade,
      'field_goals_attempted': fieldGoalsAttempted,
      'three_pointers_made': threePointersMade,
      'three_pointers_attempted': threePointersAttempted,
      'free_throws_made': freeThrowsMade,
      'free_throws_attempted': freeThrowsAttempted,
      'steals': steals,
      'blocks': blocks,
      'turnovers': turnovers,
      'personal_fouls': personalFouls,
      'minutes_played': minutesPlayed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PlayerStats.fromMap(Map<String, dynamic> map) {
    return PlayerStats(
      id: map['id'],
      gameId: map['game_id'],
      playerId: map['player_id'],
      points: map['points'] ?? 0,
      rebounds: map['rebounds'] ?? 0,
      assists: map['assists'] ?? 0,
      fieldGoalsMade: map['field_goals_made'] ?? 0,
      fieldGoalsAttempted: map['field_goals_attempted'] ?? 0,
      threePointersMade: map['three_pointers_made'] ?? 0,
      threePointersAttempted: map['three_pointers_attempted'] ?? 0,
      freeThrowsMade: map['free_throws_made'] ?? 0,
      freeThrowsAttempted: map['free_throws_attempted'] ?? 0,
      steals: map['steals'] ?? 0,
      blocks: map['blocks'] ?? 0,
      turnovers: map['turnovers'] ?? 0,
      personalFouls: map['personal_fouls'] ?? 0,
      minutesPlayed: map['minutes_played'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  PlayerStats copyWith({
    String? id,
    String? gameId,
    String? playerId,
    int? points,
    int? rebounds,
    int? assists,
    int? fieldGoalsMade,
    int? fieldGoalsAttempted,
    int? threePointersMade,
    int? threePointersAttempted,
    int? freeThrowsMade,
    int? freeThrowsAttempted,
    int? steals,
    int? blocks,
    int? turnovers,
    int? personalFouls,
    int? minutesPlayed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlayerStats(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      points: points ?? this.points,
      rebounds: rebounds ?? this.rebounds,
      assists: assists ?? this.assists,
      fieldGoalsMade: fieldGoalsMade ?? this.fieldGoalsMade,
      fieldGoalsAttempted: fieldGoalsAttempted ?? this.fieldGoalsAttempted,
      threePointersMade: threePointersMade ?? this.threePointersMade,
      threePointersAttempted: threePointersAttempted ?? this.threePointersAttempted,
      freeThrowsMade: freeThrowsMade ?? this.freeThrowsMade,
      freeThrowsAttempted: freeThrowsAttempted ?? this.freeThrowsAttempted,
      steals: steals ?? this.steals,
      blocks: blocks ?? this.blocks,
      turnovers: turnovers ?? this.turnovers,
      personalFouls: personalFouls ?? this.personalFouls,
      minutesPlayed: minutesPlayed ?? this.minutesPlayed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
