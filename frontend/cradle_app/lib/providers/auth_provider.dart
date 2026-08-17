import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String _userName = '';
  String? _token;
  String? _phone;
  bool _isLoading = false;
  Map<String, dynamic>? _userProfile;

  bool get isLoggedIn => _token != null;
  bool get isProfileCompleted => _userProfile?['isProfileCompleted'] ?? false;
  Map<String, dynamic> get profile => _userProfile ?? {};
  String get userName => _userName;
  String? get phone => _phone;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userName = prefs.getString('user_name') ?? '';
    _phone = prefs.getString('user_phone');
    if (_token != null) {
      // Optionally fetch profile from backend to verify token and get latest data
      notifyListeners();
    }
  }

  Future<void> _saveAuthData(String token, String phone, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_phone', phone);
    await prefs.setString('user_name', name);
    _token = token;
    _phone = phone;
    _userName = name;
    notifyListeners();
  }

  Future<void> login(String phone, String password) async {
    _setLoading(true);
    try {
      final response = await ApiService.post('/auth/login', {
        'phone': phone,
        'password': password,
      });
      _phone = phone;
      // Depending on backend, login might send OTP or return token
      // Our backend currently sends OTP on login
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> register(String phone, String password) async {
    _setLoading(true);
    try {
      await ApiService.post('/auth/register', {
        'phone': phone,
        'password': password,
      });
      _phone = phone;
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> verifyOtp(String code) async {
    if (_phone == null) throw Exception('Phone number missing');
    _setLoading(true);
    try {
      final response = await ApiService.post('/auth/verify-otp', {
        'phone': _phone,
        'code': code,
      });
      
      final data = response['data'];
      final token = data['token'];
      final user = data['user'];
      
      await _saveAuthData(token, user['phone'], user['full_name'] ?? '');
      _userProfile = user;
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> resendOtp() async {
    if (_phone == null) throw Exception('Phone number missing');
    _setLoading(true);
    try {
      await ApiService.post('/auth/resend-otp', {'phone': _phone});
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _token = null;
    _userName = '';
    _phone = null;
    _userProfile = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }
}
