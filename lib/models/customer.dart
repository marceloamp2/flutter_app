import 'package:personal_trx_app/models/user.dart';

class Customer {
  int id;
  String name;
  String cellphone;
  String? picture;
  int personalId;
  User user;

  Customer({
    required this.id,
    required this.name,
    required this.cellphone,
    this.picture,
    required this.personalId,
    required this.user,
  });

  Customer.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        cellphone = json['cellphone'],
        picture = json['picture'],
        personalId = json['personal_id'],
        user = User.fromJson(json['user']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'cellphone': cellphone,
        'picture': picture,
        'personal_id': personalId,
        'user': user,
      };
}
