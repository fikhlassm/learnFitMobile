import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class UserDailyStatService {
  static Future<List<dynamic>> getUserDailyStats() async {
    // Ambil token agar request tidak ditolak (401/403)
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.userDailyStats),
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
        return [];
      }
    } catch (e) {
      return []; // Return empty list agar UI tidak crash
    }
  }
}