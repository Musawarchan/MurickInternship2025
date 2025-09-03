import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { student, instructor }

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  ThemeMode _themeMode = ThemeMode.system;
  String? _email;
  String? _displayName;
  UserRole? _role;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  ThemeMode get themeMode => _themeMode;
  String? get email => _email;
  String? get displayName => _displayName;
  UserRole? get role => _role;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('auth_isAuthenticated') ?? false;
    _email = prefs.getString('auth_email');
    _displayName = prefs.getString('auth_displayName');
    final roleStr = prefs.getString('auth_role');
    if (roleStr != null) {
      _role = roleStr == 'instructor' ? UserRole.instructor : UserRole.student;
    }
    final themeStr = prefs.getString('theme_mode');
    if (themeStr != null) {
      _themeMode = themeStr == 'light'
          ? ThemeMode.light
          : themeStr == 'dark'
              ? ThemeMode.dark
              : ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> login(
      {required String email,
      required String password,
      required UserRole role}) async {
    _setLoading(true);
    _clearError();

    try {
      // Mock login logic
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _email = email;
      _displayName = email.split('@').first;
      _role = role;
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auth_isAuthenticated', true);
      await prefs.setString('auth_email', _email!);
      await prefs.setString('auth_displayName', _displayName!);
      await prefs.setString(
          'auth_role', role == UserRole.instructor ? 'instructor' : 'student');

      notifyListeners();
    } catch (e) {
      _setError('Login failed. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signup(
      {required String name,
      required String email,
      required String password,
      required UserRole role}) async {
    _setLoading(true);
    _clearError();

    try {
      // Mock signup logic
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _displayName = name;
      _email = email;
      _role = role;
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auth_isAuthenticated', true);
      await prefs.setString('auth_email', _email!);
      await prefs.setString('auth_displayName', _displayName!);
      await prefs.setString(
          'auth_role', role == UserRole.instructor ? 'instructor' : 'student');

      notifyListeners();
    } catch (e) {
      _setError('Signup failed. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _isAuthenticated = false;
    _email = null;
    _displayName = null;
    _role = null;
    _clearError();
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) => prefs.clear());
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) => prefs.setString(
        'theme_mode',
        mode == ThemeMode.light
            ? 'light'
            : mode == ThemeMode.dark
                ? 'dark'
                : 'system'));
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
