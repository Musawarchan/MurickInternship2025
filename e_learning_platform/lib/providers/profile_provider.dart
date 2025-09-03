import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  String? _name;
  String? _email;
  bool _isLoading = false;
  String? _error;
  bool _isEditing = false;

  String? get name => _name;
  String? get email => _email;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEditing => _isEditing;

  void initializeProfile(String name, String email) {
    _name = name;
    _email = email;
    notifyListeners();
  }

  void setEditing(bool editing) {
    _isEditing = editing;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Mock update logic
      await Future<void>.delayed(const Duration(milliseconds: 500));

      _name = name;
      _email = email;
      _isEditing = false;

      // Persist to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_name', _name!);
      await prefs.setString('profile_email', _email!);

      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
