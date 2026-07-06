import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String _userName = '';

  bool get isLoggedIn => _userName.isNotEmpty;
  bool get isProfileCompleted => false;
  Map<String, dynamic> get profile => {};
  String get userName => _userName;

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }
}
