import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:personal_trx_app/env.dart';
import 'package:personal_trx_app/exceptions/api_exceptions.dart';
import 'package:personal_trx_app/models/exercise.dart';
import 'package:personal_trx_app/providers/auth_provider.dart';
import 'package:personal_trx_app/views/auth/login_view.dart';

class ExerciseService {
  final String _baseUrl = baseUrl;

  Future<List<Exercise>> index(BuildContext context, String token, int exerciseGroupId) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction
        ? Uri.https(_baseUrl, '/api/exercises', {'exercise_group_id': exerciseGroupId.toString()})
        : Uri.http(_baseUrl, '/personal-trx-api/api/exercises', {'exercise_group_id': exerciseGroupId.toString()});

    final http.Response response = await http.get(_url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: "Bearer $token",
    });

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Exercise>.from(responseBody.map<Exercise>((json) => Exercise.fromJson(json)));
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

  Future<Exercise> store(BuildContext context, String token, String name, int exerciseGroupId) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction ? Uri.https(_baseUrl, '/api/exercises') : Uri.http(_baseUrl, '/personal-trx-api/api/exercises');

    final http.Response response = await http.post(_url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $token",
        },
        body: json.encode({
          'name': name,
          'exercise_group_id': exerciseGroupId,
        }));

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Exercise.fromJson(responseBody);
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

  Future<Exercise> update(BuildContext context, String token, String name, int exerciseGroupId, int exerciseId) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction ? Uri.https(_baseUrl, '/api/exercises/$exerciseId') : Uri.http(_baseUrl, '/personal-trx-api/api/exercises/$exerciseId');

    final http.Response response = await http.put(_url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $token",
        },
        body: json.encode({
          'name': name,
          'exercise_group_id': exerciseGroupId,
        }));

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Exercise.fromJson(responseBody);
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
