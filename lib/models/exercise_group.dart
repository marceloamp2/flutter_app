class ExerciseGroup {
  int id;
  String name;
  int personalId;

  ExerciseGroup({
    required this.id,
    required this.name,
    required this.personalId,
  });

  ExerciseGroup.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        personalId = json['personal_id'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'personal_id': personalId,
      };
}
