import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/order_controller.dart';
import '../widgets/order_detail_sheet.dart';

class DriverHomeView extends StatefulWidget {
  @override
  _DriverHomeViewState createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends State<DriverHomeView> {
  bool isOnline = false;
  final OrderController orderController = Get.put(OrderController());

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
              colors: [Color(0xFF059669), Color(0xFF34D399)], // Driver Green theme
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
                'Halo, Driver! 🛵',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ).animate().fade().slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              const Text(
                'Siap ambil titipan hari ini? Semangat pejuang rupiah!',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ).animate().fade(delay: 100.ms).slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
        
        // Main Status Card
        Transform.translate(
          offset: const Offset(0, -20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
          onTap: () {
            setState(() {
              isOnline = !isOnline;
              if (isOnline) {
                orderController.fetchAvailableOrders();
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isOnline 
                  ? [const Color(0xFF10B981), const Color(0xFF059669)] 
                  : (Theme.of(context).brightness == Brightness.dark 
                      ? [const Color(0xFF374151), const Color(0xFF4B5563)] 
                      : [Colors.grey.shade300, Colors.grey.shade400]),
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                if (isOnline)
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? (isOnline ? Colors.white : const Color(0xFF1F2937)) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isOnline ? Icons.electric_moped : Icons.power_settings_new,
                          color: isOnline ? const Color(0xFF10B981) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade700),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.bold, 
                              color: isOnline ? Colors.white : Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            isOnline ? 'Mencari pesanan di sekitar' : 'Ketuk untuk mulai menerima pesanan',
                            style: TextStyle(
                              fontSize: 12, 
                              color: isOnline ? Colors.white.withValues(alpha: 0.9) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: isOnline,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white.withValues(alpha: 0.3),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade500,
                    onChanged: (val) {
                      setState(() {
                        isOnline = val;
                        if (isOnline) {
                          orderController.fetchAvailableOrders();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ).animate().fade(delay: 100.ms).scale(begin: const Offset(0.95, 0.95)),
            ),
          ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
          child: Text(
            'Titipan Tersedia di Sekitarmu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ).animate().fade(delay: 200.ms),
        isOnline
            ? Obx(() {
                var pendingOrders = orderController.availableOrders.where((o) => o.status == 'pending').toList();
                if (pendingOrders.isEmpty) {
                  return _buildEmptyState('Tidak ada titipan di sekitarmu saat ini.');
                }
                return Column(
                  children: pendingOrders.map((order) => GestureDetector(
                    onTap: () => Get.bottomSheet(OrderDetailSheet(order: order), isScrollControlled: true),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.fastfood, color: Colors.amber.shade700),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.itemName,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(order.pembeliName, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.redAccent),
                                          const SizedBox(width: 4),
                                          Expanded(child: Text(order.location, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.blue.shade200),
                                          ),
                                          child: Text(
                                          order.paymentMethod,
                                          style: TextStyle(color: Colors.blue.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text('Potensi Untung: ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    Text(
                                      'Rp ${order.deliveryFee}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontSize: 16),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    orderController.acceptOrder(order);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1F2937),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                  child: const Text('Ambil'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fade(delay: (pendingOrders.indexOf(order) * 100).ms).slideY(begin: 0.1),
                  )).toList(),
                );
              })
            : _buildEmptyState('Kamu sedang offline. Aktifkan status untuk mulai menerima titipan.'),
            
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
          child: Text(
            'Titipan Yang Sedang Diambil',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ).animate().fade(delay: 300.ms),
        Obx(() {
          var driverActiveOrders = orderController.driverOrders;
          if (driverActiveOrders.isEmpty) {
            return _buildEmptyState('Belum ada pesanan yang kamu ambil.');
          }
          return Column(
            children: driverActiveOrders.map((order) => GestureDetector(
              onTap: () => Get.bottomSheet(OrderDetailSheet(order: order), isScrollControlled: true),
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delivery_dining, color: Color(0xFF10B981)),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.itemName,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(order.pembeliName, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.place_outlined, size: 16, color: Color(0xFF10B981)),
                              const SizedBox(width: 4),
                              Expanded(child: Text('Antar ke: ${order.location}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              order.paymentMethod,
                              style: TextStyle(color: Colors.blue.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            orderController.completeOrder(order);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: const Text('Selesaikan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fade(delay: (driverActiveOrders.indexOf(order) * 100).ms).slideX(begin: -0.1),
          )).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.electric_moped_outlined, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    ).animate().fade();
  }
}
