import 'package:intl/intl.dart';
import 'bill.dart';

enum ClaimStatus { draft, submitted, approved, rejected, partiallySettled }

class Claim {
  final String id;
  String patientName;
  List<Bill> bills;
  double advances;
  double settlements;
  ClaimStatus status;

  Claim({
    String? id,
    required this.patientName,
    this.bills = const [],
    this.advances = 0.0,
    this.settlements = 0.0,
    this.status = ClaimStatus.draft,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  double get totalBills => bills.fold(0.0, (sum, bill) => sum + bill.amount);
  double get pendingAmount => totalBills - advances - settlements;

  bool canTransitionTo(ClaimStatus newStatus) {
    // Business logic: Enforce workflow
    switch (status) {
      case ClaimStatus.draft:
        return newStatus == ClaimStatus.submitted;
      case ClaimStatus.submitted:
        return [ClaimStatus.approved, ClaimStatus.rejected].contains(newStatus);
      case ClaimStatus.approved:
        return newStatus == ClaimStatus.partiallySettled;
      case ClaimStatus.partiallySettled:
      case ClaimStatus.rejected:
        return false; // Terminal states
    }
  }

  void updateStatus(ClaimStatus newStatus) {
    if (canTransitionTo(newStatus)) {
      status = newStatus;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientName': patientName,
        'bills': bills.map((b) => b.toJson()).toList(),
        'advances': advances,
        'settlements': settlements,
        'status': status.toString().split('.').last,
      };

  factory Claim.fromJson(Map<String, dynamic> json) => Claim(
        id: json['id'],
        patientName: json['patientName'],
        bills: (json['bills'] as List).map((b) => Bill.fromJson(b)).toList(),
        advances: json['advances'] ?? 0.0,
        settlements: json['settlements'] ?? 0.0,
        status: ClaimStatus.values.firstWhere(
          (s) => s.toString().split('.').last == json['status'],
        ),
      );

  String get formattedTotalBills =>
      NumberFormat.currency(symbol: '₹').format(totalBills);
  String get formattedPending =>
      NumberFormat.currency(symbol: '₹').format(pendingAmount);
  String get statusLabel => status.toString().split('.').last.toUpperCase();
}
