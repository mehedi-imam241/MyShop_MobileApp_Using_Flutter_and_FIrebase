import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myshop/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expireDate;
  String _userId;
  Timer _authTImer;

  bool get isAuth {
    return token != null;
  }

  String get userID {
    return _userId;
  }

  String get token {
    if (_expireDate != null &&
        _token != null &&
        _expireDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  Future<void> signUp(String email, String password) async {
    try {
      final url =
          'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyB6WoHnERpawnrzI4M_XrFOyIG_SdLm4jI';
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      print(response.body);
      if (json.decode(response.body)['error'] != null) {
        throw HttpException(json.decode(response.body)['error']['message']);
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> signIn(String email, String password) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyB6WoHnERpawnrzI4M_XrFOyIG_SdLm4jI';

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      print(response.body);
      if (json.decode(response.body)['error'] != null) {
        throw HttpException(json.decode(response.body)['error']['message']);
      }
      _token = json.decode(response.body)['idToken'];
      _userId = json.decode(response.body)['localId'];
      _expireDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            json.decode(response.body)['expiresIn'],
          ),
        ),
      );
      autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expireDate': _expireDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    final expireDate = DateTime.parse(extractedUserData['expireDate']);
    if (expireDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expireDate = DateTime.parse(extractedUserData['expireDate']);
    autoLogout();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expireDate = null;
    if (_authTImer != null) {
      _authTImer.cancel();
      _authTImer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoLogout() {
    if (_authTImer != null) {
      _authTImer.cancel();
    }

    final timeToExpiry = _expireDate.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToExpiry), logout);
  }
}
