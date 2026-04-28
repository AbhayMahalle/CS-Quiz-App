import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final data = await _apiService.login(email, password);
      await _handleAuthSuccess(data);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      final data = await _apiService.register(name, email, password);
      await _handleAuthSuccess(data);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userName');
    
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');
    final userName = prefs.getString('userName');

    if (token != null && token.isNotEmpty && userId != null) {
      _currentUser = UserModel(
        id: userId,
        name: userName ?? 'User',
        email: '', // Not strictly needed for UI usually
        token: token,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _handleAuthSuccess(Map<String, dynamic> data) async {
    _currentUser = UserModel(
      id: data['_id'],
      name: data['name'],
      email: data['email'],
      token: data['token'],
    );
    _errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token']);
    await prefs.setString('userId', data['_id']);
    await prefs.setString('userName', data['name']);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
