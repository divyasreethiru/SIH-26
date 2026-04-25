import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'operator_panel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PrakritiGridBMS());
}

class PrakritiGridBMS extends StatelessWidget {
  const PrakritiGridBMS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prakriti Grid BMS',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const OperatorPanel(),
      debugShowCheckedModeBanner: false,
    );
  }
}
