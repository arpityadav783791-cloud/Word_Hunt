import 'package:flutter/material.dart';

import '../models/difficulty_config.dart';
import '../services/progress_service.dart';
import '../services/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.progress,
    required this.theme,
  });
  final ProgressService progress;
  final ThemeController theme;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedDifficulty = 'easy';
  bool _loadingDifficulty = true;

  @override
  void initState() {
    super.initState();
    _loadDifficulty();
  }

  Future<void> _loadDifficulty() async {
    final progress = await widget.progress.loadProgress();

    if (!mounted) return;

    setState(() {
      _selectedDifficulty = progress.preferredDifficulty;
      _loadingDifficulty = false;
    });
  }

  Future<void> _setDifficulty(String value) async {
    // Update selection immediately.
    setState(() {
      _selectedDifficulty = value;
    });

    // Remove the previous snackbar immediately.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    try {
      await widget.progress.savePreferredDifficulty(value);

      if (!mounted) return;

      // Only show confirmation for the latest selection.
      if (_selectedDifficulty != value) return;

      final level = DifficultyLevel.values.firstWhere((e) => e.name == value);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text(
            '${DifficultyConfig.forLevel(level).label} saved as your default difficulty.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted || _selectedDifficulty != value) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save difficulty: $e')));
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.theme,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Gameplay',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your choice is remembered and used automatically for regular games.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                for (final config in DifficultyConfig.all)
                  Card(
                    elevation: 0,
                    color: _selectedDifficulty == config.level.name
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerLow,
                    child: ListTile(
                      onTap: _loadingDifficulty
                          ? null
                          : () => _setDifficulty(config.level.name),
                      leading: Icon(
                        _selectedDifficulty == config.level.name
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: _selectedDifficulty == config.level.name
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(
                        config.label,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${config.gridSize} × ${config.gridSize} grid · '
                        '${config.wordCount} words\n${config.description}',
                      ),
                      isThreeLine: true,
                    ),
                  ),
              ],
            ),
            const Divider(height: 36),
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'system',
                  label: Text('System'),
                  icon: Icon(Icons.settings_suggest_outlined),
                ),
                ButtonSegment(
                  value: 'light',
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: 'dark',
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {widget.theme.themeModeName},
              onSelectionChanged: (value) {
                if (value.isNotEmpty) widget.theme.updateThemeMode(value.first);
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Text size',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text('Adjust text to make the game easier to read.'),
            Slider(
              value: widget.theme.textScale,
              min: 0.85,
              max: 1.5,
              divisions: 13,
              label: '${(widget.theme.textScale * 100).round()}%',
              onChanged: widget.theme.updateTextScale,
            ),
            Text(
              'Preview: Word Hunt',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(height: 36),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sound effects'),
              subtitle: const Text('Optional feedback sounds.'),
              value: widget.theme.soundEnabled,
              onChanged: widget.theme.updateSoundEnabled,
            ),
            const SizedBox(height: 16),
            FutureBuilder(
              future: widget.progress.loadProgress(),
              builder: (context, snapshot) {
                final p = snapshot.data;
                if (p == null){
                   return const ListTile(
                    title: Text('Saved progress'),
                    subtitle: Text('Loading…'),
                  );
                }
                 
                return ListTile(
                  leading: const Icon(Icons.bookmark_outline),
                  title: const Text('Saved progress on this device'),
                  subtitle: Text(
                    '${p.completedGames} completed games · ${p.foundWordIds.length} unique words found',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
