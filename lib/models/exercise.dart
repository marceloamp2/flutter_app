import 'package:personal_trx_app/models/exercise_group.dart';

class Exercise {
  int id;
  String name;
  String? image;
  String? videoUrl;
  int exerciseGroupId;
  ExerciseGroup exerciseGroup;

  Exercise({
    required this.id,
    required this.name,
    this.image,
    this.videoUrl,
    required this.exerciseGroupId,
    required this.exerciseGroup,
  });

  Exercise.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        image = json['image'],
        videoUrl = json['video_url'],
        exerciseGroupId = json['exercise_group_id'],
        exerciseGroup = ExerciseGroup.fromJson(json['exercise_group']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'image': image,
        'video_url': videoUrl,
        'exercise_group_id': exerciseGroupId,
        'exercise_group': exerciseGroup,
      };
}
