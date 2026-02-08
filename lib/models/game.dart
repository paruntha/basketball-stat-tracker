class Game {
  final String id;
  final String homeTeamId;
  final String awayTeamId;
  final DateTime gameDate;
  final String? location;
  final bool isComplete;
  final int homeScore;
  final int awayScore;
  final DateTime createdAt;

  Game({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.gameDate,
    this.location,
    this.isComplete = false,
    this.homeScore = 0,
    this.awayScore = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'home_team_id': homeTeamId,
      'away_team_id': awayTeamId,
      'game_date': gameDate.toIso8601String(),
      'location': location,
      'is_complete': isComplete ? 1 : 0,
      'home_score': homeScore,
      'away_score': awayScore,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'],
      homeTeamId: map['home_team_id'],
      awayTeamId: map['away_team_id'],
      gameDate: DateTime.parse(map['game_date']),
      location: map['location'],
      isComplete: map['is_complete'] == 1,
      homeScore: map['home_score'] ?? 0,
      awayScore: map['away_score'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Game copyWith({
    String? id,
    String? homeTeamId,
    String? awayTeamId,
    DateTime? gameDate,
    String? location,
    bool? isComplete,
    int? homeScore,
    int? awayScore,
    DateTime? createdAt,
  }) {
    return Game(
      id: id ?? this.id,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      gameDate: gameDate ?? this.gameDate,
      location: location ?? this.location,
      isComplete: isComplete ?? this.isComplete,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
