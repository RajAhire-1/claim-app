import 'package:uuid/uuid.dart';

class Bill {
  final String id;
  String description;
  double amount;

  Bill({String? id, required this.description, required this.amount})
      : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
      };

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        id: json['id'],
        description: json['description'],
        amount: json['amount'],
      );
}
