import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../controllers/app_controller.dart';
import '../widgets/review_dialog.dart';
import '../widgets/order_detail_sheet.dart';

class HistoryView extends StatelessWidget {
  final OrderController orderController = Get.find<OrderController>();
  final AppController appController = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDriver = appController.isDriverMode.value;
      
      // For History, we only show completed or cancelled orders.
      var completedOrders = isDriver 
        ? orderController.driverHistoryOrders.where((o) => o.status == 'completed' || o.status == 'cancelled').toList()
        : orderController.myOrders.where((o) => o.status == 'completed' || o.status == 'cancelled').toList();

      return ListView(
        padding: EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0, left: 4.0, top: 8.0),
            child: Text(
              'Riwayat Pesanan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
          if (completedOrders.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.history_toggle_off, size: 64, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade400),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Riwayat Kosong',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada riwayat pesanan yang selesai.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            Column(
              children: completedOrders.map((order) => GestureDetector(
                onTap: () => Get.bottomSheet(OrderDetailSheet(order: order), isScrollControlled: true),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.check_circle, color: Colors.blue),
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
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(order.location, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
                                  ],
                                ),
                                if (order.completedAt != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Selesai pada: ${order.completedAt!.hour}:${order.completedAt!.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ]
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rp ${order.deliveryFee}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
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
                        ],
                      ),
                    ),
                    if (order.status == 'completed') ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: order.isReviewed
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(appController.isDriverMode.value ? 'Penilaian Pembeli: ' : 'Penilaian Anda: ', style: const TextStyle(color: Colors.grey)),
                                  ...List.generate(5, (index) => Icon(
                                    index < (order.rating ?? 0) ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  )),
                                ],
                              )
                            : (!appController.isDriverMode.value ? SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Get.bottomSheet(
                                      ReviewDialog(order: order),
                                      backgroundColor: Theme.of(context).cardColor,
                                      isScrollControlled: true,
                                    );
                                  },
                                  icon: const Icon(Icons.star_outline, size: 18),
                                  label: const Text('Beri Penilaian'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.amber.shade700,
                                    side: BorderSide(color: Colors.amber.shade700, width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ) : Center(child: Text('Belum ada penilaian', style: TextStyle(color: Colors.grey.shade500)))),
                      ),
                    ]
                  ],
                ),
                ),
              )).toList(),
            ),
        ],
      );
    });
  }
}
