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

  Future<void> clearUser() async {
    await removeUser();
  }

  Future<void> saveFavorites(List<String> favorites, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_favoritesKey}_$userId';
    await prefs.setStringList(key, favorites);
    print(
      '💾 StorageService: Salvos ${favorites.length} favoritos com chave: $key',
    );
  }

  Future<List<String>> getFavorites(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_favoritesKey}_$userId';
    final result = prefs.getStringList(key) ?? [];
    print(
      '📂 StorageService: Carregados ${result.length} favoritos com chave: $key',
    );
    return result;
  }

  Future<void> saveInscricoes(List<String> inscricoes, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('${_inscricoesKey}_$userId', inscricoes);
  }

  Future<List<String>> getInscricoes(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('${_inscricoesKey}_$userId') ?? [];
  }
}
