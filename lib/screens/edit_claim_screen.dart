import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/claim.dart';
import '../models/bill.dart';
import '../providers/claim_provider.dart';
import '../widgets/status_chip.dart';
import 'dashboard_screen.dart';

class EditClaimScreen extends StatefulWidget {
  final Claim claim;
  const EditClaimScreen({super.key, required this.claim});

  @override
  State<EditClaimScreen> createState() => _EditClaimScreenState();
}

class _EditClaimScreenState extends State<EditClaimScreen> {
  late Claim _claim;
  final _advancesController = TextEditingController();
  final _settlementsController = TextEditingController();
  final _billDescriptionController = TextEditingController();
  final _billAmountController = TextEditingController();
  int? _editingBillIndex; // For edit mode

  @override
  void initState() {
    super.initState();
    // Proper deep copy: Recreate Claim and new Bill instances
    _claim = Claim(
      id: widget.claim.id,
      patientName: widget.claim.patientName,
      bills: widget.claim.bills
          .map((bill) => Bill(
                id: bill.id,
                description: bill.description,
                amount: bill.amount,
              ))
          .toList(),
      advances: widget.claim.advances,
      settlements: widget.claim.settlements,
      status: widget.claim.status,
    );
    _advancesController.text = _claim.advances.toStringAsFixed(2);
    _settlementsController.text = _claim.settlements.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _advancesController.dispose();
    _settlementsController.dispose();
    _billDescriptionController.dispose();
    _billAmountController.dispose();
    super.dispose();
  }

  void _addOrUpdateBill() {
    final desc = _billDescriptionController.text;
    final amount = double.tryParse(_billAmountController.text);
    if (desc.isNotEmpty && amount != null && amount > 0) {
      if (_editingBillIndex != null) {
        // Update existing bill
        _claim.bills[_editingBillIndex!] = Bill(
          id: _claim.bills[_editingBillIndex!].id, // Preserve ID
          description: desc,
          amount: amount,
        );
        _editingBillIndex = null;
      } else {
        // Add new bill
        _claim.bills.add(Bill(description: desc, amount: amount));
      }
      _billDescriptionController.clear();
      _billAmountController.clear();
      setState(() {});
    }
  }

  void _editBill(int index) {
    final bill = _claim.bills[index];
    _editingBillIndex = index;
    _billDescriptionController.text = bill.description;
    _billAmountController.text = bill.amount.toStringAsFixed(2);
    _showBillDialog('Edit Bill');
  }

  void _deleteBill(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Bill?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _claim.bills.removeAt(index);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBillDialog(String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _billDescriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              onSubmitted: (_) => _addOrUpdateBill(),
            ),
            TextField(
              controller: _billAmountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount (₹)'),
              onSubmitted: (_) => _addOrUpdateBill(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addOrUpdateBill();
              Navigator.pop(context);
            },
            child: Text(_editingBillIndex != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _updateTotals() {
    _claim.advances = double.tryParse(_advancesController.text) ?? 0.0;
    _claim.settlements = double.tryParse(_settlementsController.text) ?? 0.0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Claim: ${_claim.patientName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusChip(status: _claim.status),
            Text('Status: ${_claim.statusLabel}'),
            const SizedBox(height: 20),
            Text('Total Bills: ${_claim.formattedTotalBills}'),
            Text('Advances: ₹${_claim.advances.toStringAsFixed(2)}'),
            TextField(
              controller: _advancesController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _updateTotals(),
              decoration: const InputDecoration(labelText: 'Advances (₹)'),
            ),
            Text('Settlements: ₹${_claim.settlements.toStringAsFixed(2)}'),
            TextField(
              controller: _settlementsController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _updateTotals(),
              decoration: const InputDecoration(labelText: 'Settlements (₹)'),
            ),
            Text('Pending: ${_claim.formattedPending}'),
            const SizedBox(height: 20),
            const Text('Bills:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._claim.bills.asMap().entries.map((entry) {
              final index = entry.key;
              final bill = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(bill.description),
                  subtitle: Text('₹${bill.amount.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _editBill(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 20, color: Colors.red),
                        onPressed: () => _deleteBill(index),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                _editingBillIndex = null;
                _billDescriptionController.clear();
                _billAmountController.clear();
                _showBillDialog('Add New Bill');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Bill'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(height: 20),
            // Status Transition Buttons (only valid ones)
            if (_claim.canTransitionTo(ClaimStatus.submitted) ||
                _claim.canTransitionTo(ClaimStatus.approved) ||
                _claim.canTransitionTo(ClaimStatus.rejected) ||
                _claim.canTransitionTo(ClaimStatus.partiallySettled))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Update Status:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: ClaimStatus.values
                        .where((s) => _claim.canTransitionTo(s))
                        .map((s) => ElevatedButton(
                              onPressed: () {
                                _claim.updateStatus(s);
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                  s.toString().split('.').last.toUpperCase()),
                            ))
                        .toList(),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<ClaimProvider>().updateClaim(_claim);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => DashboardScreen()),
                );
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blue[600]),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
