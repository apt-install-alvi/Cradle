import 'package:flutter/material.dart';
import '../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _phoneNumber = '';
  String get phoneNumber => _phoneNumber;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _isProfileCompleted = false;
  bool get isProfileCompleted => _isProfileCompleted;

  Map<String, dynamic> _profile = {};
  Map<String, dynamic> get profile => _profile;

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  Future<bool> register(String phone, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.register(phone, password);
      _isLoading = false;
      notifyListeners();
      return res['success'] == true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.login(phone, password);
      _isLoading = false;
      notifyListeners();
      return res['success'] == true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String code) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.verifyOtp(_phoneNumber, code);
      _isLoading = false;
      if (res['success'] == true) {
        _isLoggedIn = true;
        _isProfileCompleted = res['data']['isProfileCompleted'] ?? false;
        notifyListeners();
        return true;
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchProfile() async {
    try {
      final res = await ApiService.getProfile();
      if (res['success'] == true) {
        _profile = res['data'] ?? {};
        _isProfileCompleted = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<bool> createOrUpdateProfile(
    String fullName, 
    int age, 
    String dueDate, 
    String bloodGroup, 
    List<String> history, 
    String emergencyPhone
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final profileData = {
        'fullName': fullName,
        'age': age,
        'dueDate': dueDate,
        'bloodGroup': bloodGroup,
        'medicalHistory': history,
        'emergencyContacts': [
          {'name': 'Primary Contact', 'relation': 'Emergency', 'phone': emergencyPhone}
        ]
      };
      final res = await ApiService.updateProfile(profileData);
      _isLoading = false;
      if (res['success'] == true) {
        _profile = res['data'] ?? {};
        _isProfileCompleted = true;
        notifyListeners();
        return true;
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    _isProfileCompleted = false;
    _profile = {};
    _phoneNumber = '';
    ApiService.setToken('');
    notifyListeners();
  }
}


