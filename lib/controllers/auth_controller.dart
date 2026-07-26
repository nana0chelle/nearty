import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../views/dashboard_view.dart';
import '../views/admin_home_view.dart';

class AuthController extends GetxController {
  // Status loading, dipakai untuk menampilkan indikator loading di tombol/UI
  // saat request register/login sedang berjalan.
  var isLoading = false.obs;

  /// Mendaftarkan akun baru ke backend (POST /api/register).
  ///
  /// Alur:
  /// 1. Kirim name, email, password ke server.
  /// 2. Kalau berhasil (201/200), simpan token & data user ke SharedPreferences
  ///    supaya sesi login tetap tersimpan walau app ditutup/dibuka lagi.
  /// 3. Arahkan user ke halaman yang sesuai berdasarkan role-nya
  ///    (admin -> AdminHomeView, selain itu -> DashboardView).
  /// 4. Kalau gagal (misal email sudah dipakai), tampilkan snackbar error.
  /// 5. Kalau request tidak sampai ke server sama sekali (server mati/salah
  ///    alamat), exception akan ditangkap di blok catch dan menampilkan
  ///    pesan "Could not connect to server".
  Future<void> register(String name, String email, String password) async {
    isLoading.value = true;
    try {
      // Kirim data registrasi ke endpoint backend.
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      isLoading.value = false;

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Registrasi sukses -> ambil token & data user dari response.
        final data = jsonDecode(response.body);
        String token = data['token'];
        String role = data['user']['role'] ?? 'user';
        
        // Simpan token, nama, dan role secara lokal agar user tetap "login"
        // di sesi berikutnya tanpa perlu login ulang.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_name', data['user']['name']);
        await prefs.setString('user_role', role);
        
        // Arahkan ke halaman sesuai role. Get.offAll menghapus semua
        // halaman sebelumnya dari stack navigasi (tidak bisa "back" ke
        // halaman register lagi).
        if (role == 'admin') {
          Get.offAll(() => AdminHomeView());
        } else {
          Get.offAll(() => DashboardView());
        }
      } else {
        // Registrasi ditolak server, misalnya email sudah terdaftar
        // atau data tidak valid (status code selain 200/201).
        Get.snackbar(
          'Registration Failed', 
          'Email already exists or invalid data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Request gagal total (server tidak bisa dihubungi, timeout,
      // koneksi ditolak, dll) -> bukan error validasi dari server,
      // melainkan masalah jaringan/koneksi ke backend.
      isLoading.value = false;
      Get.snackbar('Error', 'Could not connect to server', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  /// Login akun yang sudah terdaftar (POST /api/login).
  ///
  /// Alur logikanya sama persis dengan [register], bedanya endpoint yang
  /// dipanggil dan pesan error yang ditampilkan:
  /// 1. Kirim email & password ke server.
  /// 2. Kalau sukses (200), simpan token & data user, lalu arahkan ke
  ///    halaman sesuai role (admin/user).
  /// 3. Kalau email/password salah, server balas selain 200 -> tampilkan
  ///    snackbar "Invalid email or password".
  /// 4. Kalau server tidak bisa dihubungi sama sekali, tampilkan
  ///    "Could not connect to server" (bukan berarti password salah,
  ///    tapi request-nya tidak pernah sampai ke backend).
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    
    try {
      // Kirim kredensial login ke endpoint backend.
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        // Login sukses -> ambil token & data user dari response.
        final data = jsonDecode(response.body);
        String token = data['token'];
        String role = data['user']['role'] ?? 'user';
        
        // Simpan sesi login secara lokal (token, nama, role).
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_name', data['user']['name']);
        await prefs.setString('user_role', role);
        
        // Arahkan ke halaman sesuai role, sekaligus bersihkan stack
        // navigasi supaya tidak bisa "back" ke halaman login.
        if (role == 'admin') {
          Get.offAll(() => AdminHomeView());
        } else {
          Get.offAll(() => DashboardView());
        }
      } else {
        // Email/password tidak cocok, atau akun tidak ditemukan.
        Get.snackbar(
          'Login Failed', 
          'Invalid email or password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Request gagal total karena masalah koneksi/jaringan ke backend,
      // bukan karena kredensial salah.
      isLoading.value = false;
      Get.snackbar('Error', 'Could not connect to server', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}