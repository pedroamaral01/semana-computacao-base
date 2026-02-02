import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _userKey = 'current_user';
  static const String _favoritesKey = 'favorites';
  static const String _inscricoesKey = 'inscricoes';

  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return jsonDecode(userStr) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> saveInscricoes(List<String> inscricoes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_inscricoesKey, inscricoes);
  }

  Future<List<String>> getInscricoes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_inscricoesKey) ?? [];
  }
}
