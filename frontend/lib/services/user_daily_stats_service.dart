import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserDailyStatService {
  // PERBAIKAN: Gunakan localhost untuk Web/iOS Simulator
  // Ganti ke 'http://10.0.2.2:8000/api/user-daily-stats' jika pakai Android Emulator
  static const String baseUrl = 'http://localhost:8000/api/user-daily-stats';

  static Future<List<dynamic>> getUserDailyStats() async {
    // Ambil token agar request tidak ditolak (401/403)
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle struktur { "data": [ ... ] } dari Laravel
        if (data is Map && data['data'] is List) {
          return data['data'];
        }
        
        // Handle jika response langsung array
        if (data is List) {
          return data;
        }

        return [];
      } else {
        print('Error Stats: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception Stats: $e');
      return []; // Return empty list agar UI tidak crash
    }
  }
}