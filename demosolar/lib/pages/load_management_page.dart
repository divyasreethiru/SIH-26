// lib/pages/load_management_page.dart
// Load Management page.
// This page uses batteryPercentage from Firebase (or a shared BatteryModel) to decide
// which phases are active and what message to show.

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/battery_model.dart';

class LoadManagementPage extends StatefulWidget {
  final BatteryModel? sharedBatteryModel;

  const LoadManagementPage({
    super.key,
    this.sharedBatteryModel,
  });

  @override
  State<LoadManagementPage> createState() => _LoadManagementPageState();
}

class _LoadManagementPageState extends State<LoadManagementPage> {
  // Reference to Firebase battery node. Same dummy path as in battery page.
  // TODO: Change "battery" to your actual path.
  final DatabaseReference _batteryRef =
  FirebaseDatabase.instance.ref('battery'); // Dummy path.

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: _batteryRef.onValue,
      builder: (context, snapshot) {
        int batteryPercentage = 0;

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final batteryModel = BatteryModel.fromMap(data);
          batteryPercentage = batteryModel.batteryPercentage;
        } else if (widget.sharedBatteryModel != null) {
          // Fallback: use shared model from parent if available.
          batteryPercentage = widget.sharedBatteryModel!.batteryPercentage;
        }

        final bool isBatterySufficient = batteryPercentage >= 35;

        String message;
        if (isBatterySufficient) {
          message = 'All loads are active.';
        } else {
          message =
          'Due to low battery percentage only main appliances are running. Save battery extra.';
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Load Management',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Current Battery: $batteryPercentage%',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildPhaseCard(
                        phaseName: 'Phase A',
                        isActive: isBatterySufficient,
                      ),
                      _buildPhaseCard(
                        phaseName: 'Phase B',
                        isActive: isBatterySufficient,
                      ),
                      _buildPhaseCard(
                        phaseName: 'Phase C (Main)',
                        isActive: true, // Main phase is always active.
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Simple UI for a phase card that looks active or inactive.
  Widget _buildPhaseCard({
    required String phaseName,
    required bool isActive,
  }) {
    return Card(
      color: isActive ? Colors.green.shade100 : Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          phaseName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.green.shade900 : Colors.grey.shade700,
          ),
        ),
        subtitle: Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
