import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool get isLoggedIn => false;
  bool get isProfileCompleted => false;
  Map<String, dynamic> get profile => {};
}
