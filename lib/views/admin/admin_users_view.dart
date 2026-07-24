import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/admin_controller.dart';

class AdminUsersView extends StatefulWidget {
  @override
  _AdminUsersViewState createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  final AdminController adminController = Get.find();

  @override
  void initState() {
    super.initState();
    adminController.fetchUsers();
  }

  void _showEditRoleDialog(Map<String, dynamic> user) {
    String selectedRole = user['role'] ?? 'user';
    Get.defaultDialog(
      title: 'Ubah Role',
      content: StatefulBuilder(builder: (context, setState) {
        return Column(
          children: [
            RadioListTile(
              title: const Text('User'),
              value: 'user',
              groupValue: selectedRole,
              onChanged: (val) => setState(() => selectedRole = val.toString()),
            ),
            RadioListTile(
              title: const Text('Driver'),
              value: 'driver',
              groupValue: selectedRole,
              onChanged: (val) => setState(() => selectedRole = val.toString()),
            ),
            RadioListTile(
              title: const Text('Admin'),
              value: 'admin',
              groupValue: selectedRole,
              onChanged: (val) => setState(() => selectedRole = val.toString()),
            ),
          ],
        );
      }),
      textConfirm: 'Simpan',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      onConfirm: () {
        adminController.updateUserRole(user['id'], selectedRole);
        Get.back();
      },
    );
  }

  void _confirmDelete(Map<String, dynamic> user) {
    Get.defaultDialog(
      title: 'Hapus Pengguna?',
      middleText: 'Yakin ingin menghapus ${user['name']}? Tindakan ini tidak dapat dibatalkan.',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        adminController.deleteUser(user['id']);
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          'Kelola Pengguna',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4F46E5),
        centerTitle: true,
      ),
      body: Obx(() {
        if (adminController.isUsersLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
        }

        if (adminController.users.isEmpty) {
          return const Center(child: Text('Tidak ada pengguna.'));
        }

        return RefreshIndicator(
          onRefresh: adminController.fetchUsers,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: adminController.users.length,
            itemBuilder: (context, index) {
              final user = adminController.users[index];
              final role = user['role'] ?? 'user';
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF4F46E5).withOpacity(0.1),
                    child: const Icon(Icons.person, color: Color(0xFF4F46E5)),
                  ),
                  title: Text(user['name'] ?? 'Unknown', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  subtitle: Text(user['email'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: role == 'admin' ? Colors.red.withOpacity(0.1) : (role == 'driver' ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: role == 'admin' ? Colors.red : (role == 'driver' ? Colors.green : Colors.blue),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: Colors.orange),
                        onPressed: () => _showEditRoleDialog(user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () => _confirmDelete(user),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
