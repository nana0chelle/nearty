import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../views/login_view.dart';
import '../views/account_settings_view.dart';
import '../views/help_support_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatelessWidget {
  final AppController appController = Get.find<AppController>();

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Get.offAll(() => LoginView());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDriver = appController.isDriverMode.value;
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 48, bottom: 32, left: 24, right: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDriver 
                    ? [const Color(0xFF10B981), const Color(0xFF059669)]
                    : [const Color(0xFF4F46E5), const Color(0xFF1E1B4B)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDriver ? const Color(0xFF10B981) : const Color(0xFF4F46E5)).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        )
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade100,
                    child: Icon(isDriver ? Icons.motorcycle : Icons.person, size: 50, color: isDriver ? const Color(0xFF10B981) : const Color(0xFF4F46E5)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  appController.userName.value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    isDriver ? 'Driver Mode' : 'User Mode',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                    children: [

                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.swap_horiz, color: Colors.blue.shade600),
                        ),
                        title: const Text('Mode Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(isDriver ? 'Saat ini: Driver' : 'Saat ini: Pembeli', style: TextStyle(color: Colors.grey.shade600)),
                        trailing: Switch(
                          value: isDriver,
                          activeColor: const Color(0xFF10B981),
                          onChanged: (val) {
                            appController.toggleMode();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: Icon(Icons.person_outline, color: isDark ? Colors.white : Colors.black87),
                        title: const Text('Pengaturan Akun'),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () {
                          Get.to(() => const AccountSettingsView(), transition: Transition.rightToLeft);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: Icon(Icons.help_outline, color: isDark ? Colors.white : Colors.black87),
                        title: const Text('Bantuan & Dukungan'),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () {
                          Get.to(() => const HelpSupportView(), transition: Transition.rightToLeft);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: const Icon(Icons.logout, color: Colors.redAccent),
                        title: const Text('Keluar (Logout)', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
              ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
