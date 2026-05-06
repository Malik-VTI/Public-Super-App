import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../datasources/remote/api_client.dart';
import '../../core/constants/api_constants.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<String> login(String email, String password) async {
    final response = await _apiClient.dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final token = response.data['data']['token'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    return token;
  }

  Future<String> biometricLogin(String biometricKey) async {
    final response = await _apiClient.dio.post(
      ApiConstants.biometric,
      data: {'biometric_key': biometricKey},
    );
    final token = response.data['data']['token'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    return token;
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiConstants.logout);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.dio.get(ApiConstants.profile);
    return response.data['data'];
  }

  Future<Map<String, dynamic>> updateProfile(String fullName, String phone) async {
    final response = await _apiClient.dio.put(
      ApiConstants.profile,
      data: {'full_name': fullName, 'phone': phone},
    );
    return response.data['data'];
  }

  Future<String> register(String nik, String fullName, String email, String phone, String password) async {
    final response = await _apiClient.dio.post(
      ApiConstants.register,
      data: {
        'nik': nik,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
    final token = response.data['data']['token'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    return token;
  }

  Future<void> resetPassword(String email, String nik, String newPassword) async {
    await _apiClient.dio.post(
      ApiConstants.resetPassword,
      data: {
        'email': email,
        'nik': nik,
        'new_password': newPassword,
      },
    );
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
