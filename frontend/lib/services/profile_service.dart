import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart'; // Import AuthService untuk pakai helper getAuthHeaders

class ProfileService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // Atau pakai 10.0.2.2 jika di emulator Android

  /// GET /api/profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      // Ambil header dengan token otomatis dari AuthService
      final headers = await AuthService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'] ?? data, // Menangani jika backend wrap data dalam key 'data' atau tidak
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data profil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi gagal: ${e.toString()}',
      };
    }
  }

  /// PATCH /api/profile (Update Nama, Grade, dll)
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? grade,
    String? bio,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      
      // Siapkan body hanya dengan field yang diisi
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (grade != null) body['grade'] = grade;
      if (bio != null) body['bio'] = bio;

      final response = await http.patch(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data['data'] ?? data,
          'message': 'Profil berhasil diperbarui',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memperbarui profil',
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

  /// POST /api/profile/avatar (Upload Foto Profil - Opsional)
  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/avatar'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.files.add(await http.MultipartFile.fromPath('avatar', filePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data['data'] ?? data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengupload foto',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi gagal: ${e.toString()}',
      };
    }
  }
}