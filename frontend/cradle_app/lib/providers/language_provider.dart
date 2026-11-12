import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isBangla = true;

  bool get isBangla => _isBangla;
  bool get isEnglish => !_isBangla;
  String get localeCode => _isBangla ? 'bn' : 'en';

  void setLanguage(bool isBangla) {
    if (_isBangla != isBangla) {
      _isBangla = isBangla;
      notifyListeners();
    }
  }

  void setLocaleCode(String code) {
    setLanguage(code == 'bn');
  }

  void toggleLanguage() {
    _isBangla = !_isBangla;
    notifyListeners();
  }
}
