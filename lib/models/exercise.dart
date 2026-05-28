class Exercise {
  final int? id;
  final String name;
  final String muscleGroup;
  final String equipment;

  Exercise({
    this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'muscle_group': muscleGroup,
        'equipment': equipment,
      };

  factory Exercise.fromMap(Map<String, dynamic> m) => Exercise(
        id: m['id'],
        name: m['name'],
        muscleGroup: m['muscle_group'],
        equipment: m['equipment'],
      );
}
