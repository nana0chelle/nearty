import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order_controller.dart';

class AppController extends GetxController {
  // Global state to track current active mode
  var isDriverMode = false.obs;

  // Track active tab index
  var currentIndex = 0.obs;

  var userName = 'User'.obs;
  var userEmail = 'user@example.com'.obs;
  var userPhone = '08123456789'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserName();
  }

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('user_name') ?? 'User';
    userEmail.value = prefs.getString('user_email') ?? 'user@example.com';
    userPhone.value = prefs.getString('user_phone') ?? '08123456789';
    
    // Always light mode
    Get.changeThemeMode(ThemeMode.light);
  }

  Future<void> updateUserProfile(String newName, String newEmail, String newPhone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
    await prefs.setString('user_email', newEmail);
    await prefs.setString('user_phone', newPhone);
    userName.value = newName;
    userEmail.value = newEmail;
    userPhone.value = newPhone;
  }

  void toggleMode() {
    isDriverMode.value = !isDriverMode.value;
    
    // Refresh data when switching modes
    try {
      final orderController = Get.find<OrderController>();
      if (isDriverMode.value) {
        orderController.fetchAvailableOrders();
        orderController.fetchDriverActiveOrders();
        orderController.fetchDriverHistory();
      } else {
        orderController.fetchMyOrders();
      }
    } catch (e) {}

    // Show a snackbar when mode is switched
    Get.snackbar(
      'Mode Switched',
      isDriverMode.value 
          ? 'You are now in Driver Mode 🛵' 
          : 'You are now in Pembeli Mode 🛍️',
      snackPosition: SnackPosition.TOP,
      backgroundColor: isDriverMode.value ? Get.theme.colorScheme.secondary : Get.theme.primaryColor,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void changeTabIndex(int index) {
    currentIndex.value = index;
  }
}
