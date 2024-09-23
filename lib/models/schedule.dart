import 'customer.dart';

class Schedule {
  int id;
  String date;
  String startTime;
  String endTime;
  bool done;
  int customerId;
  int personalId;
  Customer customer;

  Schedule({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.done,
    required this.customerId,
    required this.personalId,
    required this.customer,
  });

  Schedule.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        date = json['date'],
        startTime = json['start_time'],
        endTime = json['end_time'],
        done = json['done'],
        customerId = json['customer_id'],
        personalId = json['personal_id'],
        customer = Customer.fromJson(json['customer']);

  Map<String, dynamic> toJson() => {
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
        'done': done,
        'customer_id': customerId,
        'personal_id': personalId,
        'customer': customer,
      };
}
