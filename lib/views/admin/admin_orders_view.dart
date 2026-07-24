import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_controller.dart';

class AdminOrdersView extends StatefulWidget {
  @override
  _AdminOrdersViewState createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  final AdminController adminController = Get.find();

  @override
  void initState() {
    super.initState();
    adminController.fetchOrders();
  }

  void _showUpdateStatusDialog(Map<String, dynamic> order) {
    String selectedStatus = order['status'] ?? 'pending';
    Get.defaultDialog(
      title: 'Update Status',
      content: StatefulBuilder(builder: (context, setState) {
        return Column(
          children: [
            RadioListTile(title: const Text('Pending'), value: 'pending', groupValue: selectedStatus, onChanged: (val) => setState(() => selectedStatus = val.toString())),
            RadioListTile(title: const Text('Accepted'), value: 'accepted', groupValue: selectedStatus, onChanged: (val) => setState(() => selectedStatus = val.toString())),
            RadioListTile(title: const Text('Picked Up'), value: 'picked_up', groupValue: selectedStatus, onChanged: (val) => setState(() => selectedStatus = val.toString())),
            RadioListTile(title: const Text('Completed'), value: 'completed', groupValue: selectedStatus, onChanged: (val) => setState(() => selectedStatus = val.toString())),
            RadioListTile(title: const Text('Cancelled'), value: 'cancelled', groupValue: selectedStatus, onChanged: (val) => setState(() => selectedStatus = val.toString())),
          ],
        );
      }),
      textConfirm: 'Simpan',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      onConfirm: () {
        adminController.updateOrderStatus(order['id'], selectedStatus);
        Get.back();
      },
    );
  }

  void _confirmDelete(Map<String, dynamic> order) {
    Get.defaultDialog(
      title: 'Hapus Pesanan?',
      middleText: 'Yakin ingin menghapus pesanan ini?',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        adminController.deleteOrder(order['id']);
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Kelola Pesanan', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4F46E5),
        centerTitle: true,
      ),
      body: Obx(() {
        if (adminController.isOrdersLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
        }

        if (adminController.orders.isEmpty) {
          return const Center(child: Text('Tidak ada pesanan.'));
        }

        return RefreshIndicator(
          onRefresh: adminController.fetchOrders,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: adminController.orders.length,
            itemBuilder: (context, index) {
              final order = adminController.orders[index];
              final status = order['status'] ?? 'unknown';
              
              Color statusColor = Colors.orange;
              if (status == 'completed') statusColor = Colors.green;
              if (status == 'cancelled') statusColor = Colors.red;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              order['item_name'] ?? 'Unknown',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('User: ${order['user'] != null ? order['user']['name'] : '-'}'),
                      Text('Driver: ${order['driver'] != null ? order['driver']['name'] : 'Belum ada'}'),
                      Text('Harga: Rp ${NumberFormat('#,###', 'id_ID').format(double.tryParse(order['fee'].toString()) ?? 0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Update Status'),
                            onPressed: () => _showUpdateStatusDialog(order),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                            label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                            onPressed: () => _confirmDelete(order),
                          ),
                        ],
                      )
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
