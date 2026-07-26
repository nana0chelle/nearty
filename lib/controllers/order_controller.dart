import 'package:get/get.dart';
import '../models/order_model.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';

class OrderController extends GetxController {
  // Daftar pesanan milik pembeli yang sedang login (tab "Pesanan Saya").
  var myOrders = <Order>[].obs;
  // Daftar pesanan berstatus 'pending' yang belum diambil driver manapun,
  // ditampilkan di halaman driver untuk dipilih/diambil.
  var availableOrders = <Order>[].obs;
  // Pesanan yang sedang dijalani oleh driver yang sedang login (belum selesai).
  var driverOrders = <Order>[].obs;
  // Riwayat pesanan driver yang sudah selesai/dibatalkan.
  var driverHistoryOrders = <Order>[].obs;
  final String baseUrl = 'http://127.0.0.1:8000/api';

  @override
  void onInit() {
    super.onInit();
    // Saat controller pertama kali dibuat, langsung tarik semua daftar
    // pesanan yang relevan (baik sebagai pembeli maupun driver) sekaligus,
    // supaya data sudah siap begitu halaman-halaman terkait dibuka.
    fetchMyOrders();
    fetchAvailableOrders();
    fetchDriverActiveOrders();
    fetchDriverHistory();
  }

  // Ambil token login yang tersimpan di SharedPreferences. Dipakai di
  // hampir semua fungsi lain untuk header Authorization: Bearer <token>.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Ambil daftar pesanan milik pembeli yang login (GET /orders/my).
  /// Hasilnya disimpan ke [myOrders] dan otomatis merefresh UI yang
  /// "mendengarkan" (Obx) variabel ini.
  Future<void> fetchMyOrders() async {
    final token = await _getToken();
    if (token == null) return; // belum login, tidak ada yang bisa diambil

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
      // Gagal diam-diam (tidak ada snackbar) supaya tidak mengganggu user
      // dengan banyak popup error setiap kali halaman dibuka/refresh.
      print('Error fetching my orders: $e');
    }
  }

  /// Ambil daftar pesanan yang masih 'pending' dan belum ada driver-nya
  /// (GET /orders/available). Dipakai di halaman driver untuk memilih
  /// pesanan mana yang mau diambil.
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

  /// Ambil pesanan yang sedang berjalan (belum selesai) milik driver yang
  /// login (GET /orders/driver/active).
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

  /// Ambil riwayat pesanan driver yang sudah selesai/dibatalkan
  /// (GET /orders/driver/history).
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

  /// Membuat pesanan baru (POST /orders).
  ///
  /// Sebelum request dikirim, ongkos kirim (fee) dihitung di sisi Flutter:
  /// - Kalau koordinat pickup & tujuan tersedia (dari peta), fee dihitung
  ///   berdasarkan jarak sebenarnya (base fee + tarif per KM, dibulatkan
  ///   ke kelipatan 500 terdekat).
  /// - Kalau koordinat tidak tersedia, dipakai fee acak sebagai fallback
  ///   (bukan berdasarkan jarak).
  ///
  /// Setelah sukses dibuat, [fetchMyOrders] dipanggil ulang supaya daftar
  /// "Pesanan Saya" langsung menampilkan pesanan yang baru dibuat.
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
        Get.snackbar('Error', 'Gagal membuat pesanan', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Error creating order: $e');
    }
  }

  /// Mengubah detail pesanan yang masih bisa diedit (PUT /orders/{id}).
  /// Hanya berlaku untuk pesanan milik pembeli itu sendiri, biasanya selama
  /// masih berstatus 'pending' (validasi kepemilikan dicek di backend).
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
        Get.snackbar('Error', 'Gagal memperbarui pesanan', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {}
  }

  /// Membatalkan pesanan milik pembeli (DELETE /orders/{id}).
  /// Di backend ini bukan hard-delete, melainkan mengubah status pesanan
  /// menjadi 'cancelled' supaya tetap muncul di riwayat.
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
        Get.snackbar('Error', 'Gagal membatalkan pesanan', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {}
  }

  /// Driver mengambil pesanan yang masih 'pending' (POST /orders/{id}/accept).
  /// Kalau berhasil: pesanan dihapus dari [availableOrders] (karena sudah
  /// ada driver-nya) dan ditambahkan ke [driverOrders] sebagai pesanan
  /// aktif milik driver ini.
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
        Get.snackbar('Error', 'Gagal mengambil pesanan', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {}
  }

  /// Driver menandai pesanan sebagai selesai (PUT /orders/{id}/status,
  /// status = 'completed'). Pesanan dipindahkan dari daftar aktif
  /// [driverOrders] ke riwayat dengan memanggil ulang [fetchDriverHistory].
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
        Get.snackbar('Sukses', 'Pesanan selesai!', backgroundColor: Colors.blue, colorText: Colors.white);
      }
    } catch (e) {}
  }

  /// Pembeli mengirim ulasan (rating + komentar) untuk pesanan yang sudah
  /// selesai (POST /orders/{orderId}/review). Setelah sukses, [fetchMyOrders]
  /// dipanggil ulang supaya data ulasan langsung terlihat di daftar pesanan.
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
        Get.snackbar('Error', 'Gagal mengirim ulasan', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {}
  }
}