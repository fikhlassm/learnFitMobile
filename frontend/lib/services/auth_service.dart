import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  /// POST /api/login
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
        String? token = 
          data['token'] ?? 
          data['access_token'] ?? 
          data['data']?['token'] ?? 
          data['data']?['access_token'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await prefs.remove('auth_token');
        return {
          'success': true,
          'message': 'Logout berhasil',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Logout gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi gagal: ${e.toString()}',
      };
    }
  }

  /// POST /api/register ← TAMBAHAN BARU
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        String? token = 
          data['token'] ?? 
          data['access_token'] ?? 
          data['data']?['token'] ?? 
          data['data']?['access_token'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        }
        
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi gagal: ${e.toString()}',
      };
    }
  }  // ← Tutup method register

  /// Helper: Get headers dengan token otomatis
  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
    /// POST /api/forgot-password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'), // Sesuaikan endpoint backendmu
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Link reset password telah dikirim ke email Anda.',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengirim link reset password.',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi gagal: ${e.toString()}',
      };
    }
  }
    /// POST /api/otp/resend
  Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/otp/resend'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'OTP resent successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to resend OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi gagal: ${e.toString()}',
      };
    }
  }

  /// POST /api/otp/verify
  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/otp/verify'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Jika backend return token setelah verifikasi, simpan di sini
        String? token = 
          data['token'] ?? 
          data['access_token'] ?? 
          data['data']?['token'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        }

        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi gagal: ${e.toString()}',
      };
    }
  }
  
}  // ← ⚠️ CLASS AuthService selesai di sini