import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About Developer')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 16),

            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: colors.primaryContainer,
                    child: Icon(
                      Icons.person_rounded,
                      size: 55,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Arpit Kumar Yadav',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Developer of Word Hunt',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'About',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Word Hunt is a puzzle game built with Flutter. '
              'This project focuses on enjoyable gameplay, '
              'thoughtful design, and a smooth user experience.',
            ),

            const SizedBox(height: 28),

            Text(
              'Contributions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            const _ContributionTile(
              icon: Icons.code_rounded,
              title: 'Application Development',
              description: 'Building the application and its architecture.',
            ),
            const _ContributionTile(
              icon: Icons.grid_view_rounded,
              title: 'Puzzle Generation',
              description:
                  'Word placement, grid generation and difficulty levels.',
            ),
            const _ContributionTile(
              icon: Icons.touch_app_rounded,
              title: 'Gameplay',
              description: 'Drag selection, word validation and game progress.',
            ),
            const _ContributionTile(
              icon: Icons.palette_outlined,
              title: 'User Experience',
              description:
                  'Interface design, themes and accessibility settings.',
            ),

            const SizedBox(height: 28),

            Card(
              elevation: 0,
              color: colors.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 32,
                      color: colors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Support Development',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enjoying Word Hunt? Your support can help '
                      'with future improvements and development.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onPrimaryContainer),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Support Word Hunt'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Scan this QR code using PhonePe or any UPI app.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Image.asset(
                                  'assets/phonepe_qr.png',
                                  width: 240,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Thank you for supporting development!',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.volunteer_activism_rounded),
                      label: const Text('Support the Developer'),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final url = Uri.parse(
                          'https://arpityadav783791-cloud.github.io/Personal_Portfolio/',
                        );

                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      icon: const Icon(Icons.language_rounded),
                      label: const Text('Visit My Website'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: Text(
                'Made with Flutter ❤️',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContributionTile extends StatelessWidget {
  const _ContributionTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(description),
    );
  }
}
