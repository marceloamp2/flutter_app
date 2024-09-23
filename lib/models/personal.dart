import 'package:personal_trx_app/models/user.dart';

class Personal {
  int id;
  String name;
  User? user;

  Personal({
    required this.id,
    required this.name,
    this.user,
  });

  Personal.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        user = json['user'] != null ? User.fromJson(json['user']) : null;

  Map<String, dynamic> toJson() => {
        'name': name,
        'user': user,
      };
}
