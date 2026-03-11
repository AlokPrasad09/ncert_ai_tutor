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

        if(res.statusCode == 200){
      return jsonDecode(res.body);
    }else{
      print(res.body);
      throw Exception("Signup failed");
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

    if(res.statusCode == 200){
      return jsonDecode(res.body);
    }else{
      print(res.body);
      throw Exception("Login failed");
    }
  }
}