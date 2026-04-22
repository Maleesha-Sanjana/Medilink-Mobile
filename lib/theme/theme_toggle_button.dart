import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    return IconButton(
      tooltip: provider.isDark ? 'Switch to Light' : 'Switch to Dark',
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => RotationTransition(
          turns: anim,
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Icon(
          provider.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(provider.isDark),
          size: 22,
        ),
      ),
      onPressed: provider.toggle,
    );
  }
}
