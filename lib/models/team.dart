class Team {
  final String id;
  final String name;
  final String? logo;
  final DateTime createdAt;

  Team({
    required this.id,
    required this.name,
    this.logo,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'],
      name: map['name'],
      logo: map['logo'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
