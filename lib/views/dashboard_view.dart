import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../controllers/order_controller.dart';
import 'pembeli_home_view.dart';
import 'driver_home_view.dart';
import 'history_view.dart';
import 'profile_view.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class DashboardView extends StatefulWidget {
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final AppController appController = Get.put(AppController());

  @override
  void initState() {
    super.initState();
    // Register OrderController sebelum halaman pembeli/driver dibangun
    Get.put(OrderController());
  }

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
          backgroundColor:
              isDriver ? const Color(0xFF059669) : const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: IndexedStack(
            index: currentIndex,
            children: [
              isDriver ? DriverHomeView() : PembeliHomeView(),
              HistoryView(),
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
                color: Colors.black.withOpacity(0.1),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor:
                    isDriver ? const Color(0xFF059669) : const Color(0xFF4F46E5),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade400
                    : Colors.black54,
                tabs: const [
                  GButton(icon: Icons.home_rounded, text: 'Beranda'),
                  GButton(icon: Icons.history_rounded, text: 'Riwayat'),
                  GButton(icon: Icons.person_rounded, text: 'Profil'),
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
