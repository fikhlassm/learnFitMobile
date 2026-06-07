import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FlashcardService {
static const String baseUrl =
'http://127.0.0.1:8000/api/flashcards';

static Future<Map<String, String>> _headers() async {
final prefs = await SharedPreferences.getInstance();

final token =
    prefs.getString('auth_token');

print(
  'FLASHCARD TOKEN = $token',
);

return {
  'Accept': 'application/json',
  'Content-Type':
      'application/json',
  'Authorization':
      'Bearer ${token ?? ''}',
};

}

static Future<List<dynamic>> getFlashcards({
required int studySessionId,
}) async {
print(
'FLASHCARD SESSION ID = $studySessionId',
);

final response = await http.get(
  Uri.parse(
    '$baseUrl?study_session_id=$studySessionId',
  ),
  headers: await _headers(),
);

print(
  'FLASHCARD GET STATUS = ${response.statusCode}',
);

print(
  'FLASHCARD GET BODY = ${response.body}',
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
  'Failed to load flashcards',
);

}

static Future<void> createFlashcard({
required int studySessionId,
required String question,
required String answer,
}) async {
print(
'CREATE FLASHCARD SESSION = $studySessionId',
);

final response = await http.post(
  Uri.parse(baseUrl),
  headers: await _headers(),
  body: jsonEncode({
    'study_session_id':
        studySessionId,
    'question': question,
    'answer': answer,
  }),
);

print(
  'CREATE STATUS = ${response.statusCode}',
);

print(
  'CREATE BODY = ${response.body}',
);

if (response.statusCode != 200 &&
    response.statusCode != 201) {
  throw Exception(
    'Failed to create flashcard',
  );
}

}

static Future<void> updateFlashcard({
required int id,
required String question,
required String answer,
}) async {
final response = await http.patch(
Uri.parse('$baseUrl/$id'),
headers: await _headers(),
body: jsonEncode({
'question': question,
'answer': answer,
}),
);

print(response.statusCode);
print(response.body);

if (response.statusCode != 200) {
  throw Exception(
    'Failed to update flashcard',
  );
}

}

static Future<void> deleteFlashcard({
required int id,
}) async {
final response = await http.delete(
Uri.parse('$baseUrl/$id'),
headers: await _headers(),
);

print(response.statusCode);
print(response.body);

if (response.statusCode != 200) {
  throw Exception(
    'Failed to delete flashcard',
  );
}

}
}
