import 'package:get/get.dart';
import '../models/order_model.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';

class OrderController extends GetxController {
  var myOrders = <Order>[].obs;
  var availableOrders = <Order>[].obs;
  var driverOrders = <Order>[].obs;
  var driverHistoryOrders = <Order>[].obs;
  final String baseUrl = 'http://172.16.11.79:8000/api';

  @override
  void onInit() {
    super.onInit();
    fetchMyOrders();
    fetchAvailableOrders();
    fetchDriverActiveOrders();
    fetchDriverHistory();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchMyOrders() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/my'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        myOrders.value = data.map((e) => Order.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching my orders: $e');
    }
  }

  Future<void> fetchAvailableOrders() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/available'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        availableOrders.value = data.map((e) => Order.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching available orders: $e');
    }
  }

  Future<void> fetchDriverActiveOrders() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/driver/active'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        driverOrders.value = data.map((e) => Order.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching driver active orders: $e');
    }
  }

  Future<void> fetchDriverHistory() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/driver/history'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        driverHistoryOrders.value = data.map((e) => Order.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching driver history: $e');
    }
  }

  Future<void> createOrder(String itemName, String pickupLocation, String destinationLocation, String paymentMethod, {double? pickupLat, double? pickupLng, double? destLat, double? destLng}) async {
    final token = await _getToken();
    
    int calculatedFee = 5000 + Random().nextInt(15) * 1000; // default fallback

    if (pickupLat != null && pickupLng != null && destLat != null && destLng != null) {
      final Distance distance = const Distance();
      final double km = distance.as(LengthUnit.Kilometer, LatLng(pickupLat, pickupLng), LatLng(destLat, destLng));
      
      // Base fee 5000, 3000 per KM
      calculatedFee = 5000 + (km * 3000).round();
      // Round to nearest 500 for cleaner numbers
      calculatedFee = (calculatedFee / 500).ceil() * 500;
      
      if (calculatedFee < 5000) calculatedFee = 5000;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'item_name': itemName,
          'pickup_location': pickupLocation,
          'destination_location': destinationLocation,
          'fee': calculatedFee,
          'payment_method': paymentMethod,
          'pickup_lat': pickupLat,
          'pickup_lng': pickupLng,
          'dest_lat': destLat,
          'dest_lng': destLng,
        }),
      );

      if (response.statusCode == 201) {
        fetchMyOrders();
        Get.snackbar('Sukses', 'Pesanan sedang dicarikan driver!', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        String errMsg = 'Gagal membuat pesanan';
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) errMsg = data['message'];
        } catch (_) {}
        Get.snackbar('Error', errMsg, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi gagal: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> updateOrder(int id, String itemName, String pickupLocation, String destinationLocation) async {
    final token = await _getToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$id'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'item_name': itemName,
          'pickup_location': pickupLocation,
          'destination_location': destinationLocation,
        }),
      );
      if (response.statusCode == 200) {
        fetchMyOrders();
        Get.snackbar('Sukses', 'Pesanan diperbarui', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        String errMsg = 'Gagal memperbarui pesanan';
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) errMsg = data['message'];
        } catch (_) {}
        Get.snackbar('Error', errMsg, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi gagal: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> deleteOrder(int id) async {
    final token = await _getToken();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/orders/$id'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        fetchMyOrders();
        Get.snackbar('Sukses', 'Pesanan dibatalkan', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        String errMsg = 'Gagal membatalkan pesanan';
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) errMsg = data['message'];
        } catch (_) {}
        Get.snackbar('Error', errMsg, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi gagal: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> acceptOrder(Order order) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/${order.id}/accept'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        fetchAvailableOrders();
        final updatedData = jsonDecode(response.body)['order'];
        driverOrders.add(Order.fromJson(updatedData));
        Get.snackbar('Sukses', 'Pesanan diambil!', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        String errMsg = 'Gagal mengambil pesanan';
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) errMsg = data['message'];
        } catch (_) {}
        Get.snackbar('Error', errMsg, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi gagal: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> pickupOrder(Order order) async {
    final token = await _getToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/${order.id}/status'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'status': 'picked_up'}),
      );
      if (response.statusCode == 200) {
        final idx = driverOrders.indexWhere((o) => o.id == order.id);
        if (idx != -1) {
          driverOrders[idx].status = 'picked_up';
          driverOrders.refresh();
        }
        Get.snackbar('Barang Diambil! 📦', 'Sekarang antar ke tujuan ya!',
            backgroundColor: const Color(0xFF4F46E5), colorText: Colors.white);
      } else {
        String errMsg = 'Gagal memperbarui status';
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) errMsg = data['message'];
        } catch (_) {}
        Get.snackbar('Error', errMsg, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi gagal: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> completeOrder(Order order) async {
    final token = await _getToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/${order.id}/status'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'status': 'completed'}),
      );
      if (response.statusCode == 200) {
        driverOrders.removeWhere((o) => o.id == order.id);
        fetchDriverHistory();
        Get.snackbar('Pesanan Selesai! 🎉', 'Kerja bagus! Lanjut cari pesanan lagi.',
            backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
      } else {
        String errMsg = 'Gagal menyelesaikan pesanan';
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) errMsg = data['message'];
        } catch (_) {}
        Get.snackbar('Error', errMsg, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi gagal: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> submitReview(int orderId, int rating, String comment) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/review'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'rating': rating,
          'comment': comment,
        }),
      );
      if (response.statusCode == 201) {
        fetchMyOrders();
        Get.snackbar('Terima Kasih!', 'Ulasan kamu berhasil dikirim.', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        String errMsg = 'Gagal mengirim ulasan';
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) errMsg = data['message'];
        } catch (_) {}
        Get.snackbar('Error', errMsg, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi gagal: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
