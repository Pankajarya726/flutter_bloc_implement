import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utility {
  static String IS_SERVICE_RUNNING = "IS_SERVICE_RUNNING";
  static String PICKUP_ADDRESS = "PICKUP_ADDRESS";
  static String DESTINATION_ADDRESS = "DESTINATION_ADDRESS";

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.black,
        fontSize: 15,
        timeInSecForIosWeb: 2,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG);
  }

  static Future<String> getStringPreference(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }

  static Future<bool> setStringPreference(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static Future<bool> setBooleanPreference(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  static Future<bool> getBooleanPreference(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<void> clearSharedPreference(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
