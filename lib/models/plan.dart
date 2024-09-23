class Plan {
  int id;
  String name;
  int durationInDays;
  num price;
  int personalId;

  Plan({
    required this.id,
    required this.name,
    required this.durationInDays,
    required this.price,
    required this.personalId,
  });

  Plan.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        durationInDays = json['duration_in_days'],
        price = json['price'],
        personalId = json['personal_id'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'duration_in_days': durationInDays,
        'price': price,
        'personal_id': personalId,
      };
}
