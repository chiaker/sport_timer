import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/sequence_list_screen.dart';
import 'services/storage.dart';
import 'screens/error_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
    await StorageService.initialize();
    runApp(const STimerApp());
  } catch (e, st) {
    runApp(ErrorApp(error: '$e\n$st'));
  }
}

class STimerApp extends StatelessWidget {
  const STimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Colors.indigo;
    return MaterialApp(
      title: 'S Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: color),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: const SequenceListScreen(),
    );
  }
}
