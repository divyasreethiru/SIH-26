// lib/operator.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class OperatorScreen extends StatelessWidget {
  const OperatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Operator Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BatteryManagementScreen(),
                  ),
                );
              },
              child: const Text('Battery Management Panel'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CleaningSystemScreen(),
                  ),
                );
              },
              child: const Text('Cleaning System Panel'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoadManagementScreen(),
                  ),
                );
              },
              child: const Text('Load Management Panel'),
            ),
          ],
        ),
      ),
    );
  }
}


// ===== BATTERY MANAGEMENT (unchanged) =====
class BatteryManagementScreen extends StatefulWidget {
  const BatteryManagementScreen({super.key});

  @override
  State<BatteryManagementScreen> createState() =>
      _BatteryManagementScreenState();
}

class _BatteryManagementScreenState extends State<BatteryManagementScreen> {
  final DatabaseReference _batteryRef =
  FirebaseDatabase.instance.ref('battery');

  Map<dynamic, dynamic>? _battery;

  @override
  void initState() {
    super.initState();
    _batteryRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        setState(() {
          _battery = data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    num? soc;
    final rawSoc = _battery?['soc'];

    if (rawSoc is num) {
      soc = rawSoc;
    } else if (rawSoc is String) {
      soc = num.tryParse(rawSoc);
    } else {
      soc = null;
    }

    final bool lowSocAlert = soc != null && soc < 30.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Battery Management')),
      body: _battery == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lowSocAlert)
              Card(
                color: Colors.red[100],
                child: const ListTile(
                  leading: Icon(Icons.warning, color: Colors.red),
                  title: Text(
                    'ALERT: State of Charge below 30%.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            _metric('Voltage', _battery?['voltage'], 'V'),
            _metric('Current', _battery?['current'], 'A'),
            _metric('Power', _battery?['power'], 'W'),
            _metric('Temperature', _battery?['temp'], '°C'),
            _metric('SOC', _battery?['soc'], '%'),
            _metric('SOH', _battery?['soh'], '%'),
            const SizedBox(height: 16),
            Text(
              'Status: ${_battery?['status'] ?? 'UNKNOWN'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, dynamic value, String unit) {
    String text;
    if (value is num) {
      text = '${value.toStringAsFixed(2)} $unit';
    } else {
      text = '-- $unit';
    }
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ===== CLEANING SYSTEM (updated with STANDBY message) =====
class CleaningSystemScreen extends StatefulWidget {
  const CleaningSystemScreen({super.key});

  @override
  State<CleaningSystemScreen> createState() => _CleaningSystemScreenState();
}

class _CleaningSystemScreenState extends State<CleaningSystemScreen> {
  final DatabaseReference _cleaningRef =
  FirebaseDatabase.instance.ref('cleaning');

  Map<dynamic, dynamic>? _cleaning;

  @override
  void initState() {
    super.initState();
    _cleaningRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        setState(() {
          _cleaning = data;
        });
      }
    });
  }

  void _startCleaning() {
    print('🔵 User tapped START button');  // Add this debug line
    FirebaseDatabase.instance.ref('cleaning/command').set('START');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cleaning command sent!')),
    );
  }


  @override
  Widget build(BuildContext context) {
    final status = _cleaning?['status']?.toString() ?? 'UNKNOWN';
    final panelVoltage = _cleaning?['panelVoltage'];

    String voltageText = '--';
    if (panelVoltage is num) {
      voltageText = '${panelVoltage.toStringAsFixed(2)} V';
    }

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;
    String statusMessage = '';

    switch (status) {
      case 'IDLE':
        statusColor = Colors.blue;
        statusIcon = Icons.visibility;
        statusMessage = 'System on Standby - Monitoring voltage...';
        break;
      case 'PENDING':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusMessage = 'Voltage drop detected! Awaiting approval.';
        break;
      case 'RUNNING':
        statusColor = Colors.green;
        statusIcon = Icons.cleaning_services;
        statusMessage = 'Cleaning in progress...';
        break;
      case 'COMPLETED':
        statusColor = Colors.teal;
        statusIcon = Icons.done_all;
        statusMessage = 'Cleaning completed successfully.';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusMessage = 'Unknown status';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cleaning System')),
      body: _cleaning == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: statusColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 50),
                    const SizedBox(height: 12),
                    Text(
                      status,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: statusColor.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.electrical_services),
                title: const Text('Panel Voltage'),
                trailing: Text(
                  voltageText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (status == 'PENDING')
              ElevatedButton.icon(
                onPressed: _startCleaning,
                icon: const Icon(Icons.play_arrow),
                label: const Text('START CLEANING'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            if (status == 'RUNNING')
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Robot is cleaning the panel...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            if (status == 'IDLE')
              Center(
                child: Column(
                  children: [
                    Icon(Icons.schedule, size: 60, color: Colors.blue.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Cleaning System is on Standby',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Waiting for voltage drop detection...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            if (status == 'COMPLETED')
              Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 60, color: Colors.teal.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'Cleaning Completed!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'System will return to standby shortly.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
// ===== LOAD MANAGEMENT (new) =====
class LoadManagementScreen extends StatefulWidget {
  const LoadManagementScreen({super.key});

  @override
  State<LoadManagementScreen> createState() => _LoadManagementScreenState();
}

class _LoadManagementScreenState extends State<LoadManagementScreen> {
  final DatabaseReference _batteryRef = FirebaseDatabase.instance.ref('battery');
  final DatabaseReference _loadsRef = FirebaseDatabase.instance.ref('loads');

  Map<dynamic, dynamic>? _battery;
  Map<dynamic, dynamic>? _loads;

  @override
  void initState() {
    super.initState();

    // Listen to battery SOC
    _batteryRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        setState(() {
          _battery = data;
        });
      }
    });

    // Listen to load status
    _loadsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        setState(() {
          _loads = data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Extract SOC
    num? soc;
    final rawSoc = _battery?['soc'];
    if (rawSoc is num) {
      soc = rawSoc;
    } else if (rawSoc is String) {
      soc = num.tryParse(rawSoc);
    }

    // Extract load states
    final loadStatus = _loads?['status']?.toString() ?? 'UNKNOWN';
    final load1Active = _loads?['load1'] == true;
    final load2Active = _loads?['load2'] == true;
    final load3Active = _loads?['load3'] == true;

    // Determine UI based on SOC
    final bool lowBattery = soc != null && soc <= 30.0;
    final String statusMessage = lowBattery
        ? 'Due to battery SOC below 30%, only the CRITICAL load is active.'
        : 'Battery SOC is healthy. All loads are active.';

    return Scaffold(
      appBar: AppBar(title: const Text('Load Management')),
      body: _battery == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SOC Display Card
            Card(
              color: lowBattery ? Colors.orange[100] : Colors.green[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.battery_charging_full,
                      size: 60,
                      color: lowBattery ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Battery SOC',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      soc != null ? '${soc.toStringAsFixed(1)}%' : '--',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: lowBattery ? Colors.orange[800] : Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Message
            Card(
              color: lowBattery ? Colors.orange[50] : Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      lowBattery ? Icons.warning : Icons.check_circle,
                      color: lowBattery ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        statusMessage,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Load Status Header
            Text(
              'Load Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            // Load 1 (Critical)
            _buildLoadCard(
              'Load 1 - Critical',
              load1Active,
              Icons.lightbulb,
              true, // always show as important
            ),
            // Load 2
            _buildLoadCard(
              'Load 2',
              load2Active,
              Icons.power,
              false,
            ),
            // Load 3
            _buildLoadCard(
              'Load 3',
              load3Active,
              Icons.power,
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadCard(String name, bool isActive, IconData icon, bool isCritical) {
    return Card(
      color: isActive ? Colors.green[50] : Colors.grey[200],
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.green : Colors.grey,
          size: 32,
        ),
        title: Row(
          children: [
            Text(name),
            if (isCritical)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'CRITICAL',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isActive ? 'ON' : 'OFF',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
