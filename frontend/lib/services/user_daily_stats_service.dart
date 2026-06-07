import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserDailyStatService {

  static const String baseUrl =
      'http://127.0.0.1:8000/api/user-daily-stats';

  static Future<Map<String, String>>
      _headers() async {

    final prefs =
        await SharedPreferences
            .getInstance();

    final token =
        prefs.getString(
          'auth_token',
        );

    print(
      'USER DAILY TOKEN = $token',
    );

    return {
      'Accept':
          'application/json',

      'Content-Type':
          'application/json',

      'Authorization':
          'Bearer ${token ?? ''}',
    };
  }

  static Future<List<dynamic>>
      getUserDailyStats() async {

    final response = await http.get(
      Uri.parse(baseUrl),

      headers:
          await _headers(),
    );

    print(
      'USER DAILY STATUS = ${response.statusCode}',
    );

    print(
      'USER DAILY BODY = ${response.body}',
    );

    if (response.statusCode == 200) {

      final data =
          jsonDecode(
        response.body,
      );

      if (data is List) {
        return data;
      }

      if (data['data'] != null) {
        return data['data'];
      }

      return [];
    }

    throw Exception(
      'Failed to load statistics',
    );
  }
}