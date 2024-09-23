import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:personal_trx_app/env.dart';
import 'package:personal_trx_app/exceptions/api_exceptions.dart';
import 'package:personal_trx_app/models/customer.dart';
import 'package:personal_trx_app/providers/auth_provider.dart';
import 'package:personal_trx_app/views/auth/login_view.dart';

class CustomerService {
  final String _baseUrl = baseUrl;

  Future<List<Customer>> index(BuildContext context, String token, int personalId) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction
        ? Uri.https(_baseUrl, '/api/customers', {'personal_id': personalId.toString()})
        : Uri.http(_baseUrl, '/personal-trx-api/api/customers', {'personal_id': personalId.toString()});

    final http.Response response = await http.get(_url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: "Bearer $token",
    });

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Customer>.from(responseBody.map<Customer>((json) => Customer.fromJson(json)));
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

  Future<Customer> store(BuildContext context, String token, String name, String email, String cellphone, int personalId) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction ? Uri.https(_baseUrl, '/api/customers') : Uri.http(_baseUrl, '/personal-trx-api/api/customers');

    final http.Response response = await http.post(_url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $token",
        },
        body: json.encode({
          'name': name,
          'email': email,
          'cellphone': cellphone,
          'personal_id': personalId,
        }));

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Customer.fromJson(responseBody);
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

  Future<Customer> update(BuildContext context, String token, String name, String email, String cellphone, int personalId, int customerId) async {
    const bool _isProduction = bool.fromEnvironment('dart.vm.product');

    Uri _url = _isProduction ? Uri.https(_baseUrl, '/api/customers/$customerId') : Uri.http(_baseUrl, '/personal-trx-api/api/customers/$customerId');

    final http.Response response = await http.put(_url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $token",
        },
        body: json.encode({
          'name': name,
          'email': email,
          'cellphone': cellphone,
          'personal_id': personalId,
        }));

    var responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Customer.fromJson(responseBody);
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
