import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {

  static Future saveHistory(List messages) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("chat_history", jsonEncode(messages));
  }

  static Future<List> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("chat_history");

    if(data == null) return [];

    return jsonDecode(data);
  }

  static Future saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
  }

}