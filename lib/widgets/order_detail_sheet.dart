import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/order_model.dart';
import '../widgets/animated_pressable.dart';

class OrderDetailSheet extends StatelessWidget {
  final Order order;

  const OrderDetailSheet({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Pesanan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(order.status).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow(Icons.shopping_bag_outlined, 'Barang Titipan', order.itemName),
            _buildDetailRow(Icons.storefront_outlined, 'Lokasi Pengambilan', order.location),
            _buildDetailRow(Icons.place_outlined, 'Lokasi Pengantaran', order.destinationLocation),
            if (order.pickupLat != null && order.pickupLng != null && order.destLat != null && order.destLng != null)
              Container(
                height: 150,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(order.pickupLat!, order.pickupLng!),
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.nearty',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(order.pickupLat!, order.pickupLng!),
                            width: 30,
                            height: 30,
                            child: const Icon(Icons.location_on, color: Colors.blue, size: 30),
                          ),
                          Marker(
                            point: LatLng(order.destLat!, order.destLng!),
                            width: 30,
                            height: 30,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 30),
                          ),
                        ],
                      ),
                      PolylineLayer(
                        polylines: <Polyline<Object>>[
                          Polyline<Object>(
                            points: [
                              LatLng(order.pickupLat!, order.pickupLng!),
                              LatLng(order.destLat!, order.destLng!),
                            ],
                            color: Colors.blue,
                            strokeWidth: 3.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(height: 32),
            _buildDetailRow(
              Icons.money_outlined, 
              'Metode Pembayaran', 
              order.paymentMethod,
              valueColor: Colors.blue.shade700,
            ),
            _buildDetailRow(
              Icons.payments_outlined, 
              'Ongkir', 
              'Rp ${order.deliveryFee}',
              valueColor: const Color(0xFF10B981),
            ),
            if (order.driverId != null) ...[
              const Divider(height: 32),
              _buildDetailRow(Icons.person_outline, 'Driver ID', order.driverId.toString()),
            ],
            if (order.completedAt != null) ...[
              const Divider(height: 32),
              _buildDetailRow(
                Icons.access_time, 
                'Waktu Selesai', 
                '${order.completedAt!.day}/${order.completedAt!.month}/${order.completedAt!.year} ${order.completedAt!.hour}:${order.completedAt!.minute.toString().padLeft(2, '0')}'
              ),
            ],
            if (order.isReviewed) ...[
              const Divider(height: 32),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.star_rounded,
                              color: Colors.amber.shade600, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text('Ulasan Pembeli',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Star row
                    Row(
                      children: [
                        ...List.generate(5, (index) => Icon(
                              index < (order.rating ?? 0)
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: Colors.amber,
                              size: 22,
                            )),
                        const SizedBox(width: 8),
                        Text(
                          '${order.rating}/5',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                    // Comment (jika ada)
                    if (order.reviewComment != null &&
                        order.reviewComment!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.amber.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.format_quote_rounded,
                                color: Colors.amber.shade400, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.reviewComment!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(Get.context!).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : const Color(0xFF374151),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Text('Tidak ada komentar.',
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                              fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AnimatedPressable(
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Tutup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  value, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 15, 
                    color: valueColor ?? (isDark ? Colors.white : const Color(0xFF1F2937)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade700;
      case 'accepted':
      case 'picked_up':
        return Colors.blue.shade700;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
