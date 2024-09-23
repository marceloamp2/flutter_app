import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:personal_trx_app/env.dart';
import 'package:personal_trx_app/exceptions/api_exceptions.dart';
import 'package:personal_trx_app/models/training_plan.dart';
import 'package:personal_trx_app/providers/auth_provider.dart';
import 'package:personal_trx_app/views/auth/login_view.dart';

class TrainingPlanService {
  final String _baseUrl = baseUrl;

  Future<List<TrainingPlan>> index(BuildContext context, String token, int customerId) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction
        ? Uri.https(_baseUrl, '/api/training-plans', {'customer_id': customerId.toString()})
        : Uri.http(_baseUrl, '/personal-trx-api/api/training-plans', {'customer_id': customerId.toString()});

    final http.Response response = await http.get(_url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: "Bearer $token",
    });

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<TrainingPlan>.from(responseBody.map<TrainingPlan>((json) => TrainingPlan.fromJson(json)));
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

  Future<TrainingPlan> store(BuildContext context, String token, String name, int personalId) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction ? Uri.https(_baseUrl, '/api/training-plans') : Uri.http(_baseUrl, '/personal-trx-api/api/training-plans');

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
      return TrainingPlan.fromJson(responseBody);
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

  Future<TrainingPlan> update(BuildContext context, String token, String name, int personalId, int exerciseGroupId) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction
        ? Uri.https(_baseUrl, '/api/training-plans/$exerciseGroupId')
        : Uri.http(_baseUrl, '/personal-trx-api/api/training-plans/$exerciseGroupId');

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
      return TrainingPlan.fromJson(responseBody);
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
