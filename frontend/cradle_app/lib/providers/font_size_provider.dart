import 'package:flutter/material.dart';

class FontSizeProvider extends ChangeNotifier {
  double _scaleFactor = 1.0;

  double get scaleFactor => _scaleFactor;

  void setScaleFactor(double value) {
    if (_scaleFactor != value) {
      _scaleFactor = value;
      notifyListeners();
    }
  }
}
