class Player {
  final String id;
  final String name;
  final String? teamId;
  final int jerseyNumber;
  final String position;
  final DateTime createdAt;

  Player({
    required this.id,
    required this.name,
    this.teamId,
    required this.jerseyNumber,
    required this.position,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'team_id': teamId,
      'jersey_number': jerseyNumber,
      'position': position,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      teamId: map['team_id'],
      jerseyNumber: map['jersey_number'],
      position: map['position'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Player copyWith({
    String? id,
    String? name,
    String? teamId,
    int? jerseyNumber,
    String? position,
    DateTime? createdAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      teamId: teamId ?? this.teamId,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
