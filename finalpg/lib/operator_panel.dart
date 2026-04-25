import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class OperatorPanel extends StatefulWidget {
  const OperatorPanel({super.key});

  @override
  State<OperatorPanel> createState() => _OperatorPanelState();
}

class _OperatorPanelState extends State<OperatorPanel> {
  final DatabaseReference _batteryRef =
  FirebaseDatabase.instance.ref('battery'); // /battery path [web:62]

  Map<dynamic, dynamic>? _batteryData;

  @override
  void initState() {
    super.initState();
    _listenToBattery();
  }

  void _listenToBattery() {
    _batteryRef.onValue.listen((event) {
      final val = event.snapshot.value;
      if (val is Map) {
        setState(() {
          _batteryData = val;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Operator Panel')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Microgrid Operator'),
            ),
            ListTile(
              leading: const Icon(Icons.battery_full),
              title: const Text('Battery Status'),
              onTap: () {
                Navigator.pop(context); // this is the first screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.sensors),
              title: const Text('Sensors (next)'),
              onTap: () {
                // to be implemented later
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_4x4),
              title: const Text('Grid Overview (next)'),
              onTap: () {
                // to be implemented later
              },
            ),
          ],
        ),
      ),
      body: _batteryData == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBatteryView(context),
    );
  }

  Widget _buildBatteryView(BuildContext context) {
    final alarms =
        (_batteryData?['alarms'] as Map?)?.cast<String, dynamic>() ?? {};

    String formatNum(dynamic v, {int frac = 2}) {
      if (v == null) return '--';
      if (v is num) return v.toStringAsFixed(frac);
      return v.toString();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Battery Status',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _metricCard(
            'Voltage',
            '${formatNum(_batteryData?['voltage'])} V',
            Icons.bolt,
          ),
          _metricCard(
            'Current',
            '${formatNum(_batteryData?['current'])} A',
            Icons.flash_on,
          ),
          _metricCard(
            'Power',
            '${formatNum(_batteryData?['power'], frac: 1)} W',
            Icons.electrical_services,
          ),
          _metricCard(
            'Temperature',
            '${formatNum(_batteryData?['temp'], frac: 1)} °C',
            Icons.thermostat,
          ),
          _metricCard(
            'SOC',
            '${formatNum(_batteryData?['soc'], frac: 1)} %',
            Icons.battery_charging_full,
          ),
          _metricCard(
            'SOH',
            '${formatNum(_batteryData?['soh'], frac: 1)} %',
            Icons.health_and_safety,
          ),
          const SizedBox(height: 24),
          Text(
            'Alerts',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (alarms.isEmpty)
            const Text('No alarm data'),
          ...alarms.entries.map((e) {
            final isAlert = e.value.toString().contains('ALERT');
            return Card(
              color: isAlert ? Colors.red[100] : Colors.green[100],
              child: ListTile(
                leading: Icon(
                  isAlert ? Icons.warning : Icons.check_circle,
                  color: isAlert ? Colors.red : Colors.green,
                ),
                title: Text(e.key.replaceAll('_', ' ').toUpperCase()),
                subtitle: Text(e.value.toString()),
              ),
            );
          }),
          const SizedBox(height: 24),
          Text(
            'Connection Status: ${_batteryData?['status'] ?? 'UNKNOWN'}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
