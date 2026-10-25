import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/operator_model.dart';

class AuthResult {
  final bool isSuccess;
  final OperatorModel? operator;
  final String? message;

  const AuthResult({
    required this.isSuccess,
    this.operator,
    this.message,
  });

  factory AuthResult.success(OperatorModel operator) {
    return AuthResult(isSuccess: true, operator: operator);
  }

  factory AuthResult.failure(String message) {
    return AuthResult(isSuccess: false, message: message);
  }
}

/// Abstract contract for authentication service
abstract class AuthService {
  Future<AuthResult> login({
    required String username,
    required String password,
  });

  Future<void> logout();

  OperatorModel? get currentOperator;
  bool get isAuthenticated => currentOperator != null;
}

/// Production API implementation that connects directly to Laravel REST API
class ApiAuthService extends AuthService {
  final http.Client _client;
  final String _baseUrl;
  OperatorModel? _currentOperator;

  ApiAuthService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConstants.baseUrl;

  @override
  OperatorModel? get currentOperator => _currentOperator;

  @override
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();

    if (trimmedUsername.isEmpty || trimmedPassword.isEmpty) {
      return AuthResult.failure('Username dan password wajib diisi.');
    }

    try {
      final uri = Uri.parse('$_baseUrl/operator/login');
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': trimmedUsername,
          'password': trimmedPassword,
        }),
      ).timeout(const Duration(seconds: 8));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        _currentOperator = OperatorModel.fromJson(data);
        return AuthResult.success(_currentOperator!);
      } else {
        final message = body['message'] as String? ?? 'Username atau password salah.';
        return AuthResult.failure(message);
      }
    } on SocketException catch (_) {
      return AuthResult.failure(
        'Tidak dapat terhubung ke server ($_baseUrl). Pastikan backend Laravel sedang berjalan (php artisan serve).',
      );
    } on TimeoutException catch (_) {
      return AuthResult.failure('Koneksi timeout. Silakan periksa jaringan server.');
    } catch (e) {
      // If error occurs, check if string mentions connection refused
      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('ClientException')) {
        return AuthResult.failure(
          'Tidak dapat terhubung ke server Laravel ($_baseUrl). Pastikan backend aktif.',
        );
      }
      return AuthResult.failure('Terjadi kesalahan: $e');
    }
  }

  @override
  Future<void> logout() async {
    if (_currentOperator?.token != null) {
      try {
        final uri = Uri.parse('$_baseUrl/operator/logout');
        await _client.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${_currentOperator!.token}',
          },
        ).timeout(const Duration(seconds: 4));
      } catch (_) {
        // Silently handle network errors during logout
      }
    }
    _currentOperator = null;
  }
}

/// Mock implementation retained for offline UI preview & unit tests
class MockAuthService extends AuthService {
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  OperatorModel? _currentOperator;

  @override
  OperatorModel? get currentOperator => _currentOperator;

  @override
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();

    if (trimmedUsername.isEmpty || trimmedPassword.isEmpty) {
      return AuthResult.failure('Username dan password wajib diisi.');
    }

    String resolveMockName(String input) {
      if (input.toLowerCase() == 'kemas') return 'Pak Kemas';
      String clean = input.contains('@') ? input.split('@').first : input;
      clean = clean.replaceAll(RegExp(r'[._\-]'), ' ').trim();
      if (clean.isEmpty) return 'Operator Smart H-EAT';
      return clean
          .split(' ')
          .where((p) => p.isNotEmpty)
          .map((p) => p[0].toUpperCase() + (p.length > 1 ? p.substring(1) : ''))
          .join(' ');
    }

    if (trimmedPassword == 'password' ||
        trimmedPassword == '123456' ||
        trimmedUsername.toLowerCase() == 'kemas' ||
        trimmedUsername.toLowerCase() == 'operator') {
      _currentOperator = OperatorModel(
        id: 1,
        name: resolveMockName(trimmedUsername),
        username: trimmedUsername,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );
      return AuthResult.success(_currentOperator!);
    }

    if (trimmedPassword.length >= 4) {
      _currentOperator = OperatorModel(
        id: 1,
        name: resolveMockName(trimmedUsername),
        username: trimmedUsername,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );
      return AuthResult.success(_currentOperator!);
    }

    return AuthResult.failure('Username atau password salah.');
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentOperator = null;
  }
}
