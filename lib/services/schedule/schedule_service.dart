import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:personal_trx_app/env.dart';
import 'package:personal_trx_app/exceptions/api_exceptions.dart';
import 'package:personal_trx_app/models/schedule.dart';
import 'package:personal_trx_app/providers/auth_provider.dart';
import 'package:personal_trx_app/views/auth/login_view.dart';

class ScheduleService {
  final String _baseUrl = baseUrl;

  Future<List<Schedule>> index(BuildContext context, String token, int personalId, DateTime selectedDay) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    String dateFormatted = '${selectedDay.year}-${selectedDay.month}-${selectedDay.day}';

    Uri _url = _isProduction
        ? Uri.https(_baseUrl, '/api/schedules', {'personal_id': personalId.toString(), 'date': dateFormatted})
        : Uri.http(_baseUrl, '/personal-trx-api/api/schedules', {'personal_id': personalId.toString(), 'date': dateFormatted});

    final http.Response response = await http.get(_url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: "Bearer $token",
    });

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Schedule>.from(responseBody.map<Schedule>((json) => Schedule.fromJson(json)));
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

  Future<Schedule> store(BuildContext context, String token, String date, String startTime, String endTime, int customerId, int personalId) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction ? Uri.https(_baseUrl, '/api/schedules') : Uri.http(_baseUrl, '/personal-trx-api/api/schedules');

    final http.Response response = await http.post(_url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $token",
        },
        body: json.encode({
          'date': date,
          'start_time': startTime,
          'end_time': endTime,
          'customer_id': customerId,
          'personal_id': personalId,
        }));

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Schedule.fromJson(responseBody);
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

  Future<bool> destroy(BuildContext context, String token, int scheduleId) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction ? Uri.https(_baseUrl, '/api/schedules/$scheduleId') : Uri.http(_baseUrl, '/personal-trx-api/api/schedules/$scheduleId');

    final http.Response response = await http.delete(_url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: "Bearer $token",
    });

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      AuthProvider _authProvider = AuthProvider(token);
      _authProvider.logout();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );

      var responseBody = jsonDecode(response.body);
      throw Exception(responseBody);
    } else {
      var responseBody = jsonDecode(response.body);
      throw ApiExceptions(responseBody['errors']);
    }
  }
}
