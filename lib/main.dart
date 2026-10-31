import 'package:flutter/material.dart';
import 'data/shared_preferences_progress_repository.dart';
import 'screens/welcome_screen.dart';
import 'services/progress_service.dart';
import 'services/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = ProgressService(SharedPreferencesProgressRepository());
  runApp(WordHuntApp(progress: progress, theme: ThemeController(progress)));
}

class WordHuntApp extends StatefulWidget {
  const WordHuntApp({super.key, required this.progress, required this.theme});
  final ProgressService progress;
  final ThemeController theme;

  @override
  State<WordHuntApp> createState() => _WordHuntAppState();
}

class _WordHuntAppState extends State<WordHuntApp> {
  @override
  void initState() {
    super.initState();
    widget.theme.load();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.theme,
    builder: (context, _) => MaterialApp(
      title: 'Word Hunt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4776E6), brightness: Brightness.light)),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4776E6), brightness: Brightness.dark)),
      themeMode: widget.theme.themeMode,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(widget.theme.textScale)),
        child: child ?? const SizedBox.shrink()),
      home: WelcomeScreen(progress: widget.progress, theme: widget.theme),
    ),
  );
}
