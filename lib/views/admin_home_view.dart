import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'admin/admin_overview_view.dart';
import 'admin/admin_users_view.dart';
import 'admin/admin_orders_view.dart';
import 'admin/admin_reviews_view.dart';
import '../controllers/admin_controller.dart';

class AdminHomeView extends StatefulWidget {
  @override
  _AdminHomeViewState createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Register AdminController agar bisa ditemukan oleh semua halaman admin
    Get.put(AdminController());
  }

  final List<Widget> _pages = [
    AdminOverviewView(),
    AdminUsersView(),
    AdminOrdersView(),
    AdminReviewsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: const Color(0xFF4F46E5),
              color: Colors.grey.shade600,
              tabs: const [
                GButton(icon: Icons.dashboard_rounded, text: 'Overview'),
                GButton(icon: Icons.people_alt_rounded, text: 'Pengguna'),
                GButton(icon: Icons.receipt_long_rounded, text: 'Pesanan'),
                GButton(icon: Icons.star_rounded, text: 'Ulasan'),
              ],
              selectedIndex: _currentIndex,
              onTabChange: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
