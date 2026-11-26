import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Exception thrown when an API request fails (non-2xx status code,
/// network error, or timeout). statusCode 0 means no response was received.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client for the MyPortfolio Django REST Framework backend.
class ApiClient {
  ApiClient({
    http.Client? client,
    this.baseUrl = apiBaseUrl,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  /// Joins baseUrl and path safely (no double or missing slash).
  Uri _uri(String path) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  Map<String, String> _headers({String? token, bool json = false}) => {
        'Accept': 'application/json',
        if (json) 'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Token $token',
      };

  /// Runs a request, converting network errors and timeouts to ApiException,
  /// and throws ApiException for non-2xx responses.
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(timeout);
    } on TimeoutException {
      throw const ApiException(0, 'Request timed out. Check your connection.');
    } on http.ClientException catch (e) {
      throw ApiException(0, 'Cannot reach server: ${e.message}');
    }
    _ensureSuccess(response);
    return response;
  }

  dynamic _decode(http.Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes));

  Future<List<Project>> getProjects() async {
    final response = await _send(
      () => _client.get(_uri('/api/v1/projects/'), headers: _headers()),
    );

    final decoded = _decode(response);

    // Supports both a plain list and DRF pagination ({"results": [...]}).
    final List<dynamic> items = decoded is Map<String, dynamic>
        ? (decoded['results'] as List<dynamic>? ?? const [])
        : decoded as List<dynamic>;

    return items
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _send(
      () => _client.post(
        _uri('/api/v1/projects/'),
        headers: _headers(token: token, json: true),
        body: jsonEncode(project.toJson()),
      ),
    );

    return Project.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _send(
      () => _client.post(
        _uri('/api/v1/auth/token/'),
        headers: _headers(json: true),
        body: jsonEncode({'username': username, 'password': password}),
      ),
    );

    final decoded = _decode(response) as Map<String, dynamic>;
    return decoded['token'] as String;
  }

  Future<void> logout({required String token}) async {
    await _send(
      () => _client.post(
        _uri('/api/v1/auth/logout/'),
        headers: _headers(token: token),
      ),
    );
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException(response.statusCode, _errorMessage(response));
  }

  /// Extracts a readable message from a DRF error body when possible.
  String _errorMessage(http.Response response) {
    try {
      final body = _decode(response);
      if (body is Map<String, dynamic>) {
        if (body['detail'] != null) return body['detail'].toString();
        return body.entries.map((e) => '${e.key}: ${e.value}').join('; ');
      }
      return body.toString();
    } catch (_) {
      return response.body;
    }
  }

  void dispose() => _client.close();
}
