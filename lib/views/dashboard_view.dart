import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import 'pembeli_home_view.dart';
import 'driver_home_view.dart';
import 'history_view.dart';
import 'profile_view.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class DashboardView extends StatelessWidget {
  final AppController appController = Get.put(AppController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDriver = appController.isDriverMode.value;
      final currentIndex = appController.currentIndex.value;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            isDriver ? 'Driver Dashboard 🛵' : 'Nearty 🛍️', 
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: isDriver ? const Color(0xFF28293E) : const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor, // Match scaffold background
          child: IndexedStack(
            index: currentIndex,
            children: [
              // Home Tab (Index 0)
              isDriver ? DriverHomeView() : PembeliHomeView(),
              // History Tab (Index 1)
              HistoryView(),
              // Profile Tab (Index 2)
              ProfileView(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withValues(alpha: 0.1),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                activeColor: Colors.white,
                iconSize: 24,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: isDriver ? const Color(0xFF28293E) : const Color(0xFF4F46E5),
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.black54,
                tabs: [
                  GButton(
                    icon: Icons.home_outlined,
                    text: 'Beranda',
                  ),
                  GButton(
                    icon: Icons.history_outlined,
                    text: 'Riwayat',
                  ),
                  GButton(
                    icon: Icons.person_outline,
                    text: 'Profil',
                  ),
                ],
                selectedIndex: currentIndex,
                onTabChange: (index) {
                  appController.changeTabIndex(index);
                },
              ),
            ),
          ),
        ),
      );
    });
  }
}
