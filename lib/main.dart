import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/sequence_list_screen.dart';
import 'services/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await StorageService.initialize();
  runApp(const STimerApp());
}

class STimerApp extends StatelessWidget {
  const STimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SequenceListScreen(),
    );
  }
}
