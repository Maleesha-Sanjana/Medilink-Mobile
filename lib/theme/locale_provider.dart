import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  String get languageLabel {
    switch (_locale.languageCode) {
      case 'si':
        return 'සිං';
      case 'ta':
        return 'தமி';
      default:
        return 'EN';
    }
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}
