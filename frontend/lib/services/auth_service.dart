import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Simpan token jika ada di response
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);
        }
        
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi gagal: ${e.toString()}',
      };
    }
  }
    /// POST /api/logout
  Future<Map<String, dynamic>> logout() async {
    try {
      // 1. Ambil token dari storage untuk auth header
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // 2. Kirim request ke backend
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          // Laravel Sanctum/API Token authentication
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      // 3. Cek response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Hapus token dari local storage
        await prefs.remove('auth_token');

        return {
          'success': true,
          'message': 'Logout berhasil',
        };
      } else {
        // ❌ Backend return error message
        return {
          'success': false,
          'message': data['message'] ?? 'Logout gagal',
        };
      }
    } catch (e) {
      // ❌ Network error / server down
      return {
        'success': false,
        'message': 'Koneksi gagal: ${e.toString()}',
      };
    }
  }
}
