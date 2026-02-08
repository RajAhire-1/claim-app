import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/claim.dart';

class ClaimCard extends StatelessWidget {
  final Claim claim;

  const ClaimCard({super.key, required this.claim});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  claim.patientName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(claim.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    claim.statusLabel,
                    style: TextStyle(
                      color: _getStatusColor(claim.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${claim.formattedTotalBills}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Pending: ${claim.formattedPending}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: claim.totalBills,
                      color: Colors.blue[400],
                      radius: 40,
                      title: 'Bills',
                      titleStyle:
                          const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    PieChartSectionData(
                      value: claim.pendingAmount,
                      color: Colors.orange[400],
                      radius: 40,
                      title: 'Pending',
                      titleStyle:
                          const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ClaimStatus s) {
    switch (s) {
      case ClaimStatus.draft:
        return Colors.grey;
      case ClaimStatus.submitted:
        return Colors.blue;
      case ClaimStatus.approved:
        return Colors.green;
      case ClaimStatus.rejected:
        return Colors.red;
      case ClaimStatus.partiallySettled:
        return Colors.orange;
    }
  }
}
