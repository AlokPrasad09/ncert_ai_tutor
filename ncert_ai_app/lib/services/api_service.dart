import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {

  static Future askAI(String question, String token) async {

    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/ask"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "messages":[
          {"role":"user","content":question}
        ]
      }),
    );

    return jsonDecode(res.body);
  }
}