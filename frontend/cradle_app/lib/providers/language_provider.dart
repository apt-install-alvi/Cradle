import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isBangla = true;

  bool get isBangla => _isBangla;
  bool get isEnglish => !_isBangla;
  
  void setLanguage(bool isBangla) {
    if (_isBangla != isBangla) {
      _isBangla = isBangla;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    _isBangla = !_isBangla;
    notifyListeners();
  }
}
