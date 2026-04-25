// lib/pages/cleaning_page.dart
// Cleaning System page.
// This page reads a voltage value (panelVoltage) from Firebase under "/cleaning"
// and uses a simple Timer + setState logic to show cleaning status.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CleaningSystemPage extends StatefulWidget {
  const CleaningSystemPage({super.key});

  @override
  State<CleaningSystemPage> createState() => _CleaningSystemPageState();
}

class _CleaningSystemPageState extends State<CleaningSystemPage> {
  // Reference to Firebase cleaning node.
  // TODO: Change "cleaning" to your actual path.
  final DatabaseReference _cleaningRef =
  FirebaseDatabase.instance.ref('cleaning'); // Dummy path.

  static const double CLEANING_THRESHOLD_VOLTAGE = 15.0;
  double _panelVoltage = 0.0;

  String _statusText = 'No cleaning required.';
  Timer? _cleaningTimer;

  @override
  void dispose() {
    _cleaningTimer?.cancel();
    super.dispose();
  }

  void _startCleaningTimer() {
    // Cancel any existing timer first.
    _cleaningTimer?.cancel();

    // Show "Cleaning in progress..." immediately.
    setState(() {
      _statusText = 'Cleaning in progress...';
    });

    // After 1 minute, change to "Cleaning done."
    _cleaningTimer = Timer(const Duration(minutes: 1), () {
      if (!mounted) return;
      setState(() {
        _statusText = 'Cleaning done.';
      });
    });
  }

  void _cancelCleaningTimerIfRunning() {
    if (_cleaningTimer != null && _cleaningTimer!.isActive) {
      _cleaningTimer!.cancel();
    }
    _cleaningTimer = null;
  }

  void _updateStatusBasedOnVoltage(double voltage) {
    if (voltage < CLEANING_THRESHOLD_VOLTAGE) {
      // Cleaning needed.
      _startCleaningTimer();
    } else {
      // No cleaning required.
      _cancelCleaningTimerIfRunning();
      setState(() {
        _statusText = 'No cleaning required.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: _cleaningRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final voltageRaw = data['panelVoltage'] ?? 0;
          _panelVoltage = (voltageRaw as num).toDouble();
          // Update cleaning status based on latest voltage.
          _updateStatusBasedOnVoltage(_panelVoltage);
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Cleaning System',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Placeholder icon + text for dual-axis solar system.
                Column(
                  children: const [
                    Icon(
                      Icons.solar_power,
                      size: 60,
                      color: Colors.orange,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Dual-Axis Solar Panel System',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Panel Voltage: ${_panelVoltage.toStringAsFixed(2)} V',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  _statusText,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
