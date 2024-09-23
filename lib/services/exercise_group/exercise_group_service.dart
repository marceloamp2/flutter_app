import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:personal_trx_app/env.dart';
import 'package:personal_trx_app/exceptions/api_exceptions.dart';
import 'package:personal_trx_app/models/exercise_group.dart';
import 'package:personal_trx_app/providers/auth_provider.dart';
import 'package:personal_trx_app/views/auth/login_view.dart';

class ExerciseGroupService {
  final String _baseUrl = baseUrl;

  Future<List<ExerciseGroup>> index(BuildContext context, String token) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction ? Uri.https(_baseUrl, '/api/exercise-groups') : Uri.http(_baseUrl, '/personal-trx-api/api/exercise-groups');

    final http.Response response = await http.get(_url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: "Bearer $token",
    });

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<ExerciseGroup>.from(responseBody.map<ExerciseGroup>((json) => ExerciseGroup.fromJson(json)));
    } else if (response.statusCode == 401) {
      AuthProvider _authProvider = AuthProvider(token);
      _authProvider.logout();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
      throw Exception(responseBody);
    } else {
      throw ApiExceptions(responseBody['errors']);
    }
  }

  Future<ExerciseGroup> store(BuildContext context, String token, String name, int personalId) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction ? Uri.https(_baseUrl, '/api/exercise-groups') : Uri.http(_baseUrl, '/personal-trx-api/api/exercise-groups');

    final http.Response response = await http.post(_url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $token",
        },
        body: json.encode({
          'name': name,
          'personal_id': personalId,
        }));

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return ExerciseGroup.fromJson(responseBody);
    } else if (response.statusCode == 401) {
      AuthProvider _authProvider = AuthProvider(token);
      _authProvider.logout();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
      throw Exception(responseBody);
    } else {
      throw ApiExceptions(responseBody['errors']);
    }
  }

  Future<ExerciseGroup> update(BuildContext context, String token, String name, int personalId, int exerciseGroupId) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction
        ? Uri.https(_baseUrl, '/api/exercise-groups/$exerciseGroupId')
        : Uri.http(_baseUrl, '/personal-trx-api/api/exercise-groups/$exerciseGroupId');

    final http.Response response = await http.put(_url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $token",
        },
        body: json.encode({
          'name': name,
          'personal_id': personalId,
        }));

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return ExerciseGroup.fromJson(responseBody);
    } else if (response.statusCode == 401) {
      AuthProvider _authProvider = AuthProvider(token);
      _authProvider.logout();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
      throw Exception(responseBody);
    } else {
      throw ApiExceptions(responseBody['errors']);
    }
  }
}
