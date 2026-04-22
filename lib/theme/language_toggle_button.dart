import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'locale_provider.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();

    return PopupMenuButton<Locale>(
      tooltip: 'Change Language',
      offset: const Offset(0, 40),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white30
                : Colors.black26,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          provider.languageLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1A1A1A),
          ),
        ),
      ),
      itemBuilder: (_) => [
        _item(context, const Locale('en'), 'English', provider.locale),
        _item(context, const Locale('si'), 'සිංහල', provider.locale),
        _item(context, const Locale('ta'), 'தமிழ்', provider.locale),
      ],
      onSelected: (locale) => provider.setLocale(locale),
    );
  }

  PopupMenuItem<Locale> _item(
    BuildContext context,
    Locale locale,
    String label,
    Locale current,
  ) {
    final isSelected = current.languageCode == locale.languageCode;
    return PopupMenuItem(
      value: locale,
      child: Row(
        children: [
          if (isSelected)
            const Icon(Icons.check_rounded, size: 16, color: Color(0xFF2D3A8C))
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              color: isSelected ? const Color(0xFF2D3A8C) : null,
            ),
          ),
        ],
      ),
    );
  }
}
