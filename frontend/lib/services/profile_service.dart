import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Import AuthService untuk pakai helper getAuthHeaders
import '../config/api_config.dart';

class ProfileService {

  /// GET /api/profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      // Ambil header dengan token otomatis dari AuthService
      final headers = await AuthService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse(ApiConfig.profile),
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

  /// PATCH /api/profile (Update Nama, Email, Grade, dll)
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? grade,
    String? bio,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      // Siapkan body hanya dengan field yang diisi
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (grade != null) body['grade'] = grade;
      if (bio != null) body['bio'] = bio;

      final response = await http.patch(
        Uri.parse(ApiConfig.profile),
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
}