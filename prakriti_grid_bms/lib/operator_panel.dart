import 'package:flutter/material.dart';
import 'battery_monitoring.dart';
import 'cleaning_bot_page.dart';

class OperatorPanel extends StatefulWidget {
  const OperatorPanel({super.key});

  @override
  State<OperatorPanel> createState() => _OperatorPanelState();
}

class _OperatorPanelState extends State<OperatorPanel> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    BatteryMonitoringPage(),
    SettingsPage(),
    CleaningBotPage(), // NEW
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Prakriti Grid Operator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.battery_full), label: 'Battery BMS'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.cleaning_services), label: 'Cleaning'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Prakriti Grid',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Operator Panel Active',
            style: TextStyle(fontSize: 16, color: Colors.green.shade600),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      StatusTile('Nodes', '1/1', Colors.green),
                      StatusTile('Batteries', 'ONLINE', Colors.green),
                      StatusTile('Solar', '1.0 kW', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const ListTile(
          leading: Icon(Icons.wifi),
          title: Text('WiFi Status'),
          subtitle: Text('Configured on ESP32'),
        ),
        const ListTile(
          leading: Icon(Icons.cloud),
          title: Text('Firebase'),
          subtitle: Text('Realtime Database connected'),
        ),
        ListTile(
          leading: const Icon(Icons.warning),
          title: const Text('Alert Thresholds'),
          subtitle: const Text('Overheat 45°C, Low SOC 20%'),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Alert Thresholds'),
                content: const Text(
                    'Currently fixed in ESP32 firmware.\nYou can make them configurable later.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK')),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class StatusTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatusTile(this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
