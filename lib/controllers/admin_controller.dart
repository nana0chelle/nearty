import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminController extends GetxController {
  var isLoading = false.obs;
  var totalUsers = 0.obs;
  var totalOrders = 0.obs;
  var activeOrders = 0.obs;
  var totalRevenue = 0.0.obs;
  var recentOrders = [].obs;

  var users = [].obs;
  var isUsersLoading = false.obs;

  var orders = [].obs;
  var isOrdersLoading = false.obs;

  var reviews = [].obs;
  var isReviewsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  // ========== DASHBOARD ==========
  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) { isLoading.value = false; return; }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/admin/dashboard'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        totalUsers.value = data['total_users'] ?? 0;
        totalOrders.value = data['total_orders'] ?? 0;
        activeOrders.value = data['active_orders'] ?? 0;
        totalRevenue.value = double.tryParse(data['total_revenue'].toString()) ?? 0.0;
        recentOrders.value = data['recent_orders'] ?? [];
      } else {
        Get.snackbar('Error', 'Server: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi gagal: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ========== USERS ==========
  Future<void> fetchUsers() async {
    isUsersLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/admin/users'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        users.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat pengguna');
    } finally {
      isUsersLoading.value = false;
    }
  }

  Future<void> updateUserRole(int userId, String newRole) async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/admin/users/$userId'),
        headers: _headers(token),
        body: jsonEncode({'role': newRole}),
      );
      if (response.statusCode == 200) {
        Get.snackbar('Berhasil', 'Role pengguna diperbarui');
        fetchUsers();
      } else {
        Get.snackbar('Error', 'Gagal memperbarui role');
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi gagal');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/admin/users/$userId'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        Get.snackbar('Berhasil', 'Pengguna dihapus');
        fetchUsers();
        fetchDashboardData();
      } else {
        Get.snackbar('Error', 'Gagal menghapus pengguna');
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi gagal');
    }
  }

  // ========== ORDERS ==========
  Future<void> fetchOrders() async {
    isOrdersLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/admin/orders'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        orders.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat pesanan');
    } finally {
      isOrdersLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/admin/orders/$orderId/status'),
        headers: _headers(token),
        body: jsonEncode({'status': status}),
      );
      if (response.statusCode == 200) {
        Get.snackbar('Berhasil', 'Status pesanan diperbarui');
        fetchOrders();
        fetchDashboardData();
      } else {
        Get.snackbar('Error', 'Gagal memperbarui status');
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi gagal');
    }
  }

  Future<void> deleteOrder(int orderId) async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/admin/orders/$orderId'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        Get.snackbar('Berhasil', 'Pesanan dihapus');
        fetchOrders();
        fetchDashboardData();
      } else {
        Get.snackbar('Error', 'Gagal menghapus pesanan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi gagal');
    }
  }

  // ========== REVIEWS ==========
  Future<void> fetchReviews() async {
    isReviewsLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/admin/reviews'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        reviews.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat ulasan');
    } finally {
      isReviewsLoading.value = false;
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/admin/reviews/$reviewId'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        Get.snackbar('Berhasil', 'Ulasan dihapus');
        fetchReviews();
      } else {
        Get.snackbar('Error', 'Gagal menghapus ulasan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi gagal');
    }
  }
}
