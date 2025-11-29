import 'package:flutter/material.dart';

class AuthService {
  // Mock user data
  static final Map<String, Map<String, dynamic>> _users = {
    'test@test.com': {
      'password': 'password',
      'name': 'Test User',
      'phone': '1234567890',
      'profilePictureUrl': null,
      'dateOfBirth': DateTime(2000, 1, 1),
    },
  };

  static String? _currentUserEmail;

  String? get currentUserEmail => _currentUserEmail;

  Map<String, dynamic>? get currentUserData {
    if (_currentUserEmail != null && _users.containsKey(_currentUserEmail!)) {
      return _users[_currentUserEmail!];
    }
    return null;
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_users.containsKey(email) && _users[email]!['password'] == password) {
      _currentUserEmail = email;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUserEmail = null;
  }

  Future<bool> register(String email, String password, String name, String phone, String? profilePictureUrl, DateTime? dateOfBirth) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_users.containsKey(email)) {
      return false; 
    }
    _users[email] = {
      'password': password,
      'name': name,
      'phone': phone,
      'profilePictureUrl': profilePictureUrl,
      'dateOfBirth': dateOfBirth,
    };
    return true;
  }

  Future<void> updateUserData(String email, {String? name, String? phone, String? profilePictureUrl, DateTime? dateOfBirth}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_users.containsKey(email)) {
      if (name != null) _users[email]!['name'] = name;
      if (phone != null) _users[email]!['phone'] = phone;
      if (profilePictureUrl != null) _users[email]!['profilePictureUrl'] = profilePictureUrl;
      if (dateOfBirth != null) _users[email]!['dateOfBirth'] = dateOfBirth;
    }
  }

  Future<bool> sendPasswordResetCode(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return _users.containsKey(email);
  }

  Future<bool> verifyCode(String code) async {
    await Future.delayed(const Duration(seconds: 1));
    return code == '123456';
  }

  Future<bool> resetPassword(String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
