class BodyWeight {
  final int? id;
  final double weight;
  final DateTime loggedAt;

  BodyWeight({this.id, required this.weight, required this.loggedAt});

  Map<String, dynamic> toMap() => {
        'id': id,
        'weight': weight,
        'logged_at': loggedAt.toIso8601String(),
      };

  factory BodyWeight.fromMap(Map<String, dynamic> m) => BodyWeight(
        id: m['id'],
        weight: (m['weight'] as num).toDouble(),
        loggedAt: DateTime.parse(m['logged_at']),
      );
}
