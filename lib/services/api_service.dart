import 'dart:convert';

import 'package:file_picker/file_picker.dart';
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

      return Map<String, dynamic>.from(data);
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

  static Future<Map<String, dynamic>>
      getDashboard() async {
    final token = await getToken();

    if (token == null) {
      throw Exception(
        'Token tidak ditemukan.',
      );
    }

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/dashboard',
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      data['message'] ??
          'Gagal mengambil dashboard.',
    );
  }

  static Future<List<dynamic>>
      getLetters() async {
    final token = await getToken();

    if (token == null) {
      throw Exception(
        'Token tidak ditemukan.',
      );
    }

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/letters',
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data['data'] ?? [];
    }

    throw Exception(
      data['message'] ??
          'Gagal mengambil data surat.',
    );
  }

  static Future<Map<String, dynamic>>
      getLetterDetail(
    int id,
  ) async {
    final token = await getToken();

    if (token == null) {
      throw Exception(
        'Token tidak ditemukan.',
      );
    }

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/letters/$id',
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return Map<String, dynamic>.from(
        data['data'],
      );
    }

    throw Exception(
      data['message'] ??
          'Gagal mengambil detail surat.',
    );
  }

  static Future<List<dynamic>>
      getLetterTypes() async {
    final token = await getToken();

    if (token == null) {
      throw Exception(
        'Token tidak ditemukan.',
      );
    }

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/letter-types',
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data['data'] ?? [];
    }

    throw Exception(
      data['message'] ??
          'Gagal mengambil jenis surat.',
    );
  }

  static Future<Map<String, dynamic>>
      createLetter({
    required int letterTypeId,
    required String purpose,
    String? deliveryMethod,
    required PlatformFile ktpFile,
    required PlatformFile kkFile,
    PlatformFile? supportingFile,
  }) async {
    final token = await getToken();

    if (token == null) {
      throw Exception(
        'Token tidak ditemukan.',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiConfig.baseUrl}/letters',
      ),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields['letter_type_id'] =
        letterTypeId.toString();

    request.fields['purpose'] = purpose;

    if (deliveryMethod != null &&
        deliveryMethod.isNotEmpty) {
      request.fields['delivery_method'] =
          deliveryMethod;
    }

    request.files.add(
      await _platformFileToMultipart(
        'ktp',
        ktpFile,
      ),
    );

    request.files.add(
      await _platformFileToMultipart(
        'kk',
        kkFile,
      ),
    );

    if (supportingFile != null) {
      request.files.add(
        await _platformFileToMultipart(
          'supporting_document',
          supportingFile,
        ),
      );
    }

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      data['message'] ??
          'Gagal mengajukan surat.',
    );
  }

  static Future<http.MultipartFile>
      _platformFileToMultipart(
    String fieldName,
    PlatformFile file,
  ) async {
    if (file.bytes != null) {
      return http.MultipartFile.fromBytes(
        fieldName,
        file.bytes!,
        filename: file.name,
      );
    }

    if (file.path != null) {
      return await http.MultipartFile.fromPath(
        fieldName,
        file.path!,
        filename: file.name,
      );
    }

    throw Exception(
      'File ${file.name} tidak dapat dibaca.',
    );
  }

  static Future<void> logout() async {
    final token = await getToken();

    if (token != null) {
      await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/logout',
        ),
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