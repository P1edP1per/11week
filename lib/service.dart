import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Service {
  Future<void> loginByNumberAndPassword(
      String phoneNumber, String password, context) async {
    http.Response response = await http.post(Uri.parse(
        'https://7food.kz/api/auth/login?phone=$phoneNumber&password=$password'));

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', json.decode(response.body)['token']);
      prefs.setString('id', json.decode(response.body)['id'].toString());
      print('Logged in');
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SignInPage()));
    } else {
      print(response.statusCode);
    }
  }
}
