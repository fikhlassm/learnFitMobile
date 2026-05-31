import 'dart:convert';
import 'package:http/http.dart' as http;

class UserDailyStatService {

  static const String baseUrl =
      'http://10.0.2.2:8000/api/user-daily-stats';

  static Future<List<dynamic>>
      getUserDailyStats() async {

    final response = await http.get(
      Uri.parse(baseUrl),

      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {

      final data =
          jsonDecode(response.body);

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