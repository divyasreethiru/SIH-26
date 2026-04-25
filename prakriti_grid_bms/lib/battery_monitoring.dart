import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class BatteryMonitoringPage extends StatefulWidget {
  const BatteryMonitoringPage({super.key});

  @override
  State<BatteryMonitoringPage> createState() => _BatteryMonitoringPageState();
}

class _BatteryMonitoringPageState extends State<BatteryMonitoringPage> {
  final DatabaseReference _batteryRef =
  FirebaseDatabase.instance.ref('battery');

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Alerts
            StreamBuilder<DatabaseEvent>(
              stream: _batteryRef.child('alarms').onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final value = snapshot.data!.snapshot.value;
                if (value == null) return const SizedBox.shrink();
                final alarms = Map<String, dynamic>.from(
                    value as Map<Object?, Object?>);
                final active =
                alarms.values.where((v) => v != 'OK').toList();
                if (active.isEmpty) return const SizedBox.shrink();

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning,
                              color: Colors.red, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'ACTIVE ALERTS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final msg in active)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            msg.toString(),
                            style:
                            TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            // Main data
            StreamBuilder<DatabaseEvent>(
              stream: _batteryRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Waiting for ESP32 data...'),
                      ],
                    ),
                  );
                }

                final data = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value
                    as Map<Object?, Object?>);

                final soc = (data['soc'] ?? 50).toDouble();
                final soh = (data['soh'] ?? 95).toDouble();
                final voltage = (data['voltage'] ?? 13.2).toDouble();
                final current = (data['current'] ?? 1.2).toDouble();
                final power = (data['power'] ?? 15.8).toDouble();
                final temp = (data['temp'] ?? 32.5).toDouble();
                final status = data['status']?.toString() ?? 'UNKNOWN';

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Last Update: ${DateTime.now().toString().substring(11, 19)}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _GaugeCard(
                              label: 'SOC',
                              value: soc,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _GaugeCard(
                              label: 'SOH',
                              value: soh,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.5,
                        children: [
                          _metricCard(
                              'Voltage',
                              '${voltage.toStringAsFixed(2)} V',
                              Icons.bolt),
                          _metricCard(
                              'Current',
                              '${current.toStringAsFixed(1)} A',
                              Icons.flash_on),
                          _metricCard(
                              'Power',
                              '${power.toStringAsFixed(0)} W',
                              Icons.electrical_services),
                          _metricCard(
                              'Temp',
                              '${temp.toStringAsFixed(1)} °C',
                              Icons.thermostat),
                        ],
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: ListTile(
                        contentPadding:
                        const EdgeInsets.all(20),
                        leading: Icon(
                          status == 'ONLINE'
                              ? Icons.wifi
                              : Icons.wifi_off,
                          color: status == 'ONLINE'
                              ? Colors.green
                              : Colors.red,
                          size: 40,
                        ),
                        title: const Text(
                          'Connection Status',
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(status),
                        trailing: Chip(
                          label: Text(status),
                          backgroundColor: status == 'ONLINE'
                              ? Colors.green
                              : Colors.red,
                          labelStyle: const TextStyle(
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugeCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _GaugeCard(
      {required this.label,
        required this.value,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
            const SizedBox(height: 8),
            CircularProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              strokeWidth: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor:
              AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _metricCard(String title, String value, IconData icon) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 32,
              color: Colors.blue.shade600),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600])),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}
