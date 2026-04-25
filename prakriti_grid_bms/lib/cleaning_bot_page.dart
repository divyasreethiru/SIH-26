import 'package:flutter/material.dart';

class CleaningBotPage extends StatelessWidget {
  const CleaningBotPage({super.key});

  @override
  Widget build(BuildContext context) {
    // MOCK values for now (no Firebase/ESP32 wiring)
    const double panelVoltage = 0.85; // simulate voltage drop
    const double threshold = 1.0;
    final bool isLowVoltage = panelVoltage < threshold;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Solar Cleaning Bot',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manual control for panel cleaner',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.green.shade600),
            ),
            const SizedBox(height: 24),

            // Voltage + alert card
            Card(
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Panel Voltage',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '${panelVoltage.toStringAsFixed(2)} V',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight:
                            FontWeight.bold,
                            color: isLowVoltage
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '(threshold: ${threshold.toStringAsFixed(2)} V)',
                          style: TextStyle(
                              color:
                              Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (panelVoltage /
                          (threshold * 2))
                          .clamp(0.0, 1.0),
                      backgroundColor:
                      Colors.grey[200],
                      valueColor:
                      AlwaysStoppedAnimation<
                          Color>(
                        isLowVoltage
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          isLowVoltage
                              ? Icons
                              .warning_amber
                              : Icons
                              .check_circle,
                          color: isLowVoltage
                              ? Colors.orange
                              : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isLowVoltage
                                ? 'Voltage drop detected. Panel may be dusty.'
                                : 'Voltage normal. Cleaning not required.',
                            style: TextStyle(
                                color:
                                Colors.grey[800]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Start cleaning button (only when low voltage)
            if (isLowVoltage)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // UI-only: just show a snackbar for now
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Start Cleaning pressed (ESP32 control will be added later).'),
                      ),
                    );
                  },
                  icon: const Icon(
                      Icons.cleaning_services),
                  label: const Text(
                    'Start Cleaning',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold),
                  ),
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.green,
                    foregroundColor:
                    Colors.white,
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                          30),
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Text(
                  'Cleaning not required at this time.',
                  style: TextStyle(
                      color: Colors.grey[700]),
                ),
              ),

            const Spacer(),

            // Status chips
            Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: const [
                Chip(
                  label: Text('Bot Status: READY'),
                  backgroundColor:
                  Color(0xFFA5D6A7),
                ),
                Chip(
                  label: Text('Mode: Manual'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
