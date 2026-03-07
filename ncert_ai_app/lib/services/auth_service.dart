import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {

  static Future signup(String email,String password) async {

    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/signup"),
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "email":email,
        "password":password
      }),
    );

    return res;
  }

  static Future login(String email,String password) async {

    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/login"),
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "email":email,
        "password":password
      }),
    );

    return jsonDecode(res.body);
  }
}