import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../widgets/order_detail_sheet.dart';
import '../views/map_picker_view.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PembeliHomeView extends StatelessWidget {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController locationController = TextEditingController(); // Lokasi Ambil
  final TextEditingController destController = TextEditingController(); // Lokasi Antar
  final OrderController orderController = Get.put(OrderController());

  final RxString paymentMethod = 'Cash'.obs;
  final Rx<LatLng?> pickupCoord = Rx<LatLng?>(null);
  final Rx<LatLng?> destCoord = Rx<LatLng?>(null);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Beautiful Banner
        Container(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Halo, Pembeli! 👋',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ).animate().fade().slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              const Text(
                'Mau titip apa hari ini? Biar kami yang antar.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ).animate().fade(delay: 100.ms).slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
        
        // Main Form Card
        Transform.translate(
          offset: const Offset(0, -20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                  controller: itemController,
                  decoration: const InputDecoration(
                    labelText: 'Apa yang ingin Anda titip?',
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Lokasi Pengambilan (Toko/Resto)',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.map, color: Colors.blue),
                      onPressed: () async {
                        final LatLng? result = await Get.to(() => MapPickerView(
                          title: 'Pilih Lokasi Pengambilan',
                          initialPosition: pickupCoord.value ?? const LatLng(-6.200000, 106.816666),
                        ));
                        if (result != null) {
                          pickupCoord.value = result;
                          locationController.text = '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: destController,
                  decoration: InputDecoration(
                    labelText: 'Lokasi Pengantaran (Tujuan Anda)',
                    prefixIcon: const Icon(Icons.home_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.map, color: Colors.green),
                      onPressed: () async {
                        final LatLng? result = await Get.to(() => MapPickerView(
                          title: 'Pilih Lokasi Tujuan',
                          initialPosition: destCoord.value ?? const LatLng(-6.200000, 106.816666),
                        ));
                        if (result != null) {
                          destCoord.value = result;
                          destController.text = '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Obx(() {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => paymentMethod.value = 'Cash',
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: paymentMethod.value == 'Cash' ? const Color(0xFF4F46E5).withOpacity(0.1) : (isDark ? const Color(0xFF374151) : Colors.grey.shade50),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: paymentMethod.value == 'Cash' ? const Color(0xFF4F46E5) : (isDark ? Colors.white24 : Colors.grey.shade300),
                                width: paymentMethod.value == 'Cash' ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.money, color: paymentMethod.value == 'Cash' ? const Color(0xFF4F46E5) : (isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                                const SizedBox(width: 8),
                                Text('Cash', style: TextStyle(
                                  color: paymentMethod.value == 'Cash' ? const Color(0xFF4F46E5) : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                                  fontWeight: paymentMethod.value == 'Cash' ? FontWeight.bold : FontWeight.normal,
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => paymentMethod.value = 'QRIS',
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: paymentMethod.value == 'QRIS' ? const Color(0xFF4F46E5).withOpacity(0.1) : (isDark ? const Color(0xFF374151) : Colors.grey.shade50),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: paymentMethod.value == 'QRIS' ? const Color(0xFF4F46E5) : (isDark ? Colors.white24 : Colors.grey.shade300),
                                width: paymentMethod.value == 'QRIS' ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.qr_code_scanner, color: paymentMethod.value == 'QRIS' ? const Color(0xFF4F46E5) : (isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                                const SizedBox(width: 8),
                                Text('QRIS', style: TextStyle(
                                  color: paymentMethod.value == 'QRIS' ? const Color(0xFF4F46E5) : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                                  fontWeight: paymentMethod.value == 'QRIS' ? FontWeight.bold : FontWeight.normal,
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (itemController.text.isNotEmpty && locationController.text.isNotEmpty && destController.text.isNotEmpty) {
                        orderController.createOrder(
                          itemController.text, 
                          locationController.text, 
                          destController.text, 
                          paymentMethod.value,
                          pickupLat: pickupCoord.value?.latitude,
                          pickupLng: pickupCoord.value?.longitude,
                          destLat: destCoord.value?.latitude,
                          destLng: destCoord.value?.longitude,
                        );
                        Get.snackbar(
                          'Berhasil', 
                          'Pesanan "${itemController.text}" sedang dicarikan driver!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF10B981),
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 16,
                        );
                        itemController.clear();
                        locationController.clear();
                        destController.clear();
                        paymentMethod.value = 'Cash'; // reset
                        pickupCoord.value = null;
                        destCoord.value = null;
                      } else {
                        Get.snackbar(
                          'Perhatian', 
                          'Mohon lengkapi semua informasi pesanan.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orangeAccent,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 16,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: const Color(0xFF4F46E5).withValues(alpha: 0.4),
                    ),
                    child: const Text('Buat Pesanan', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ), // closes Column
          ), // closes inner Padding
        ), // closes Card
      ), // closes outer Padding
    ).animate().fade(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)), // closes Transform.translate
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text('Titipan Aktif Saya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color))
              .animate().fade(delay: 300.ms),
        ),
        Obx(() {
          if (orderController.myOrders.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text('Belum ada pesanan aktif.', style: TextStyle(color: Colors.grey.shade500)),
              ),
            ).animate().fade();
          } else {
            return Column(
              children: orderController.myOrders.map((order) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Card(
                    elevation: 2,
                    shadowColor: Colors.black.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Get.bottomSheet(
                          OrderDetailSheet(order: order),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.shopping_bag, color: Color(0xFF4F46E5), size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.itemName,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.storefront, size: 14, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(order.location, style: TextStyle(color: Colors.grey.shade600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.place, size: 14, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(order.destinationLocation, style: TextStyle(color: Colors.grey.shade600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(order.status).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: _getStatusColor(order.status).withValues(alpha: 0.3)),
                                        ),
                                        child: Text(
                                          order.status.toUpperCase(),
                                          style: TextStyle(
                                            color: _getStatusColor(order.status),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: Text(
                                          order.paymentMethod,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                if (order.status == 'pending') ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showEditDialog(context, order),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => orderController.deleteOrder(order.id),
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate().fade().slideY(begin: 0.1, end: 0);
              }).toList(),
            );
          }
        }),
      ],
    );
  }

  void _showEditDialog(BuildContext context, order) {
    final TextEditingController editItemController = TextEditingController(text: order.itemName);
    final TextEditingController editPickupController = TextEditingController(text: order.location);
    final TextEditingController editDestController = TextEditingController(text: order.destinationLocation);
    
    Get.defaultDialog(
      title: 'Edit Pesanan',
      content: Column(
        children: [
          TextField(controller: editItemController, decoration: InputDecoration(labelText: 'Barang')),
          TextField(controller: editPickupController, decoration: InputDecoration(labelText: 'Lokasi Ambil')),
          TextField(controller: editDestController, decoration: InputDecoration(labelText: 'Lokasi Antar')),
        ],
      ),
      textConfirm: 'Simpan',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      onConfirm: () {
        orderController.updateOrder(
          order.id, 
          editItemController.text, 
          editPickupController.text, 
          editDestController.text
        );
        Get.back();
      }
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'on_process': return Colors.blue;
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
