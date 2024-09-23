class User {
  int? id;
  String email;
  bool active;
  int userableId;
  String userableType;

  User({
    this.id,
    required this.email,
    required this.active,
    required this.userableId,
    required this.userableType,
  });

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        email = json['email'],
        active = json['active'],
        userableId = json['userable_id'],
        userableType = json['userable_type'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'active': active,
        'userable_id': userableId,
        'userable_type': userableType,
      };
}
