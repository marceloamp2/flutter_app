import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:personal_trx_app/exceptions/api_exceptions.dart';
import 'package:personal_trx_app/models/user.dart';

import '../../env.dart';

class UserService {
  final String _baseUrl = baseUrl;
  final String _token;

  UserService(this._token);

  Future<User> show() async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction ? Uri.https(_baseUrl, '/api/user') : Uri.http(_baseUrl, '/personal-trx-api/api/user');

    final http.Response response = await http.get(_url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: "Bearer $_token",
    });

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return User.fromJson(responseBody);
    } else {
      throw ApiExceptions(responseBody['errors']);
    }
  }

  Future<User> update(userId, password, passwordConfirmation) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction ? Uri.https(_baseUrl, '/api/users/$userId') : Uri.http(_baseUrl, '/personal-trx-api/api/users/$userId');

    final http.Response response = await http.put(_url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $_token",
        },
        body: json.encode({
          'password': password,
          'password_confirmation': passwordConfirmation,
        }));

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return User.fromJson(responseBody);
    } else {
      throw ApiExceptions(responseBody['errors']);
    }
  }
}
