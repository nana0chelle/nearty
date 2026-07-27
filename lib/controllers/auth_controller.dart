import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../views/dashboard_view.dart';
import '../views/admin_home_view.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;

  Future<void> register(String name, String email, String password) async {
    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('http://172.16.11.79:8000/api/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      isLoading.value = false;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['token'];
        String role = data['user']['role'] ?? 'user';
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_name', data['user']['name']);
        await prefs.setString('user_role', role);
        
        if (role == 'admin') {
          Get.offAll(() => AdminHomeView());
        } else {
          Get.offAll(() => DashboardView());
        }
      } else {
        Get.snackbar(
          'Registration Failed', 
          'Email already exists or invalid data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Could not connect to server', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    
    try {
      final response = await http.post(
        Uri.parse('http://172.16.11.79:8000/api/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['token'];
        String role = data['user']['role'] ?? 'user';
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_name', data['user']['name']);
        await prefs.setString('user_role', role);
        
        if (role == 'admin') {
          Get.offAll(() => AdminHomeView());
        } else {
          Get.offAll(() => DashboardView());
        }
      } else {
        Get.snackbar(
          'Login Failed', 
          'Invalid email or password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Could not connect to server', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
