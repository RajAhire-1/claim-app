import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/claim.dart';
import '../providers/claim_provider.dart';
import 'dashboard_screen.dart';

class CreateClaimScreen extends StatefulWidget {
  const CreateClaimScreen({super.key});

  @override
  State<CreateClaimScreen> createState() => _CreateClaimScreenState();
}

class _CreateClaimScreenState extends State<CreateClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Claim')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(labelText: 'Patient Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final claim =
                        Claim(patientName: _patientNameController.text);
                    context.read<ClaimProvider>().addClaim(claim);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DashboardScreen()),
                    );
                  }
                },
                child: const Text('Create Draft Claim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
