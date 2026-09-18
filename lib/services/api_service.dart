import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final token = data['token'];

      if (token != null) {
        await _storage.write(
          key: 'auth_token',
          value: token,
        );
      }

      return data;
    }

    throw Exception(
      data['message'] ?? 'Login gagal.',
    );
  }

  static Future<String?> getToken() async {
    return await _storage.read(
      key: 'auth_token',
    );
  }

  static Future<Map<String, dynamic>> getDashboard() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan.');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/dashboard'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data['message'] ??
          'Gagal mengambil dashboard.',
    );
  }

  static Future<void> logout() async {
    final token = await getToken();

    if (token != null) {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    }

    await _storage.delete(
      key: 'auth_token',
    );
  }
}