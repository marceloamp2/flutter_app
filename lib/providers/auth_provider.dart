import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final storage = const FlutterSecureStorage();
  String _token;

  AuthProvider(this._token);

  String get getToken {
    return _token;
  }

  set setToken(String value) {
    _token = value;
  }

  bool get isAuthenticated {
    return getToken != '';
  }

  Future<void> login(String token) async {
    setToken = token;
    await storage.write(key: 'token', value: token);
    notifyListeners();
  }

  Future<void> logout() async {
    setToken = '';
    await storage.delete(key: 'token');
    notifyListeners();
  }

  Future<void> autoLogin() async {
    if (!isAuthenticated) {
      String tokenStored = await storage.read(key: 'token') ?? '';
      if (tokenStored != '') {
        setToken = tokenStored;
        notifyListeners();
      }
    }
  }
}
