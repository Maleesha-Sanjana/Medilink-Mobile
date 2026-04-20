import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/theme_toggle_button.dart';
import '../../theme/language_toggle_button.dart';
import '../../l10n/app_localizations.dart';
import '../login_screen.dart';

class EmtDashboard extends StatelessWidget {
  const EmtDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'STJ MediLink',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A237E),
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.top,
                child: Text(
                  '\u207A',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A237E),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          const ThemeToggleButton(),
          const LanguageToggleButton(),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Builder(
        builder: (context) {
          final l = AppLocalizations.of(context)!;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emergency_rounded,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  l.ambulanceDashboard,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.welcomeDriver,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
