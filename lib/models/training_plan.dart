import 'package:personal_trx_app/models/plan.dart';

class TrainingPlan {
  int id;
  String name;
  String objective;
  String difficulty;
  String startDate;
  String endDate;
  int customerId;
  int planId;
  Plan plan;

  TrainingPlan({
    required this.id,
    required this.name,
    required this.objective,
    required this.difficulty,
    required this.startDate,
    required this.endDate,
    required this.customerId,
    required this.planId,
    required this.plan,
  });

  TrainingPlan.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        objective = json['objective'],
        difficulty = json['difficulty'],
        startDate = json['start_date'],
        endDate = json['end_date'],
        customerId = json['customer_id'],
        planId = json['plan_id'],
        plan = Plan.fromJson(json['plan']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'objective': objective,
        'difficulty': difficulty,
        'start_date': startDate,
        'end_date': endDate,
        'customer_id': customerId,
        'plan_id': planId,
        'plan': plan,
      };
}
