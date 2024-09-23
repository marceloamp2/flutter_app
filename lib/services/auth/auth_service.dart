import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:personal_trx_app/exceptions/api_exceptions.dart';

import '../../env.dart';

class AuthService {
  final String _baseUrl = baseUrl;

  Future<String> login(String email, String password) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction ? Uri.https(_baseUrl, '/api/login') : Uri.http(_baseUrl, '/personal-trx-api/api/login');

    final http.Response response = await http.post(_url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      var responseBody = jsonDecode(response.body);
      throw ApiExceptions(responseBody['errors']);
    }
  }

  Future<Map<String, dynamic>> userable(token) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction ? Uri.https(_baseUrl, '/api/userable') : Uri.http(_baseUrl, '/personal-trx-api/api/userable');

    final http.Response response = await http.get(_url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: "Bearer $token",
    });

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw ApiExceptions(responseBody['errors']);
    }
  }
}
