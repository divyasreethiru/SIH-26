// lib/pages/battery_detail_page.dart
// Detail screen for a single battery parameter.
// It shows the name, current value, and a short explanation.

import 'package:flutter/material.dart';

class BatteryDetailPage extends StatelessWidget {
  final String parameterName;
  final String parameterValue;
  final String description;

  const BatteryDetailPage({
    super.key,
    required this.parameterName,
    required this.parameterValue,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(parameterName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              parameterName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Current Value: $parameterValue',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
