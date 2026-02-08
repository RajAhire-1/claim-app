import 'package:flutter/material.dart';
import 'package:insurance_claim_app/models/bill.dart';
import '../models/claim.dart';

class ClaimProvider with ChangeNotifier {
  List<Claim> _claims = [
    // Sample data to demo dashboard
    Claim(
        patientName: 'Pratiksha Ahire',
        bills: [Bill(description: 'Consultation', amount: 5000)]),
    Claim(patientName: 'Yash Ahire', status: ClaimStatus.approved),
  ];

  List<Claim> get claims => _claims;

  void addClaim(Claim claim) {
    _claims.add(claim);
    notifyListeners();
  }

  void updateClaim(Claim updatedClaim) {
    final index = _claims.indexWhere((c) => c.id == updatedClaim.id);
    if (index != -1) {
      _claims[index] = updatedClaim;
      notifyListeners();
    }
  }

  void deleteClaim(String id) {
    _claims.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
