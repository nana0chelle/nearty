import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../widgets/order_detail_sheet.dart';
import '../views/map_picker_view.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/animated_pressable.dart';

// ── Status config untuk stepper pembeli ────────────────────────────────────
class _BuyerStatusConfig {
  static const steps  = ['pending',  'accepted',            'picked_up',          'completed'];
  static const labels = ['Menunggu', 'Driver\nMenuju Toko', 'Dalam\nPerjalanan', 'Selesai'];
  static const icons  = [
    Icons.schedule_rounded,
    Icons.store_rounded,
    Icons.delivery_dining_rounded,
    Icons.check_circle_rounded,
  ];
  static const colors = [
    Color(0xFFF59E0B),
    Color(0xFF4F46E5),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
  ];

  static int indexOf(String status) {
    final i = steps.indexOf(status);
    return i < 0 ? 0 : i;
  }

  static Color colorOf(String status) => colors[indexOf(status)];
  static IconData iconOf(String status) => icons[indexOf(status)];
  static String labelOf(String status) {
    switch (status) {
      case 'pending':   return 'Menunggu';
      case 'accepted':  return 'Diambil';
      case 'picked_up': return 'Diantarkan';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default:          return status;
    }
  }
}

class PembeliHomeView extends StatefulWidget {
  @override
  State<PembeliHomeView> createState() => _PembeliHomeViewState();
}


class _PembeliHomeViewState extends State<PembeliHomeView>
    with SingleTickerProviderStateMixin {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController destController = TextEditingController();
  final OrderController orderController = Get.put(OrderController());

  final RxString paymentMethod = 'Cash'.obs;
  final Rx<LatLng?> pickupCoord = Rx<LatLng?>(null);
  final Rx<LatLng?> destCoord = Rx<LatLng?>(null);

  late AnimationController _pulseController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    itemController.dispose();
    locationController.dispose();
    destController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RefreshIndicator(
      onRefresh: () async {
        await orderController.fetchMyOrders();
      },
      color: const Color(0xFF4F46E5),
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // ── HEADER BANNER ─────────────────────────────────────────────
        _buildHeader(isDark),

        // ── ORDER FORM ────────────────────────────────────────────────
        Transform.translate(
          offset: const Offset(0, -24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildOrderForm(isDark),
          ),
        ),

        // ── ACTIVE ORDERS SECTION ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Titipan Aktif Saya',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${orderController.myOrders.length} pesanan',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4F46E5),
                      ),
                    ),
                  )),
            ],
          ),
        ).animate().fade(delay: 350.ms),

        Obx(() {
          if (orderController.myOrders.isEmpty) {
            return _buildEmptyState(isDark);
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: orderController.myOrders.asMap().entries.map((entry) {
                final idx = entry.key;
                final order = entry.value;
                return _buildOrderCard(order, idx, isDark);
              }).toList(),
            ),
          );
        }),

        const SizedBox(height: 40),
      ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -10,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Opacity(
                opacity: 0.07 + _pulseController.value * 0.05,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.shopping_bag_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mode Pembeli',
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 13)),
                      Text(
                        'Halo, Pembeli! 👋',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fade().slideY(begin: 0.3, end: 0),
              const SizedBox(height: 12),
              Text(
                'Mau titip apa hari ini?\nBiar kami yang ambilkan! 🛍️',
                style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.85), fontSize: 14),
              ).animate().fade(delay: 120.ms).slideY(begin: 0.3, end: 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderForm(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_shopping_cart_rounded,
                      color: Color(0xFF4F46E5), size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  'Buat Titipan Baru',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Item name field
            TextField(
              controller: itemController,
              decoration: const InputDecoration(
                labelText: 'Apa yang ingin dititip?',
                prefixIcon: Icon(Icons.shopping_bag_outlined),
              ),
            ),
            const SizedBox(height: 14),

            // Pickup location field
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Lokasi Pengambilan',
                prefixIcon: const Icon(Icons.store_mall_directory_outlined),
                suffixIcon: _mapButton(
                  color: const Color(0xFF4F46E5),
                  onTap: () async {
                    final LatLng? result = await Get.to(
                      () => MapPickerView(
                        title: 'Pilih Lokasi Pengambilan',
                        initialPosition:
                            pickupCoord.value ?? const LatLng(-6.200000, 106.816666),
                      ),
                    );
                    if (result != null) {
                      pickupCoord.value = result;
                      locationController.text =
                          '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Destination field
            TextField(
              controller: destController,
              decoration: InputDecoration(
                labelText: 'Lokasi Pengantaran',
                prefixIcon: const Icon(Icons.home_outlined),
                suffixIcon: _mapButton(
                  color: const Color(0xFF10B981),
                  onTap: () async {
                    final LatLng? result = await Get.to(
                      () => MapPickerView(
                        title: 'Pilih Lokasi Tujuan',
                        initialPosition:
                            destCoord.value ?? const LatLng(-6.200000, 106.816666),
                      ),
                    );
                    if (result != null) {
                      destCoord.value = result;
                      destController.text =
                          '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Payment method
            Text(
              'Metode Pembayaran',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => Row(
                  children: [
                    Expanded(child: _buildPaymentChip('Cash', Icons.money_rounded, isDark)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildPaymentChip('QRIS', Icons.qr_code_scanner_rounded, isDark)),
                  ],
                )),

            const SizedBox(height: 22),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: StatefulBuilder(
                builder: (_, setBtn) => AnimatedPressable(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (itemController.text.isEmpty ||
                          locationController.text.isEmpty ||
                          destController.text.isEmpty) {
                        Get.snackbar(
                          'Perhatian',
                          'Mohon lengkapi semua informasi pesanan.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orangeAccent,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 16,
                        );
                        return;
                      }
                      setBtn(() => _submitting = true);
                      await orderController.createOrder(
                        itemController.text,
                        locationController.text,
                        destController.text,
                        paymentMethod.value,
                        pickupLat: pickupCoord.value?.latitude,
                        pickupLng: pickupCoord.value?.longitude,
                        destLat: destCoord.value?.latitude,
                        destLng: destCoord.value?.longitude,
                      );
                      itemController.clear();
                      locationController.clear();
                      destController.clear();
                      paymentMethod.value = 'Cash';
                      pickupCoord.value = null;
                      destCoord.value = null;
                      setBtn(() => _submitting = false);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      backgroundColor: const Color(0xFF4F46E5),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _submitting
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : Row(
                              key: const ValueKey('text'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Buat Pesanan Sekarang',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(delay: 200.ms).scale(begin: const Offset(0.97, 0.97));
  }

  Widget _mapButton({required Color color, required VoidCallback onTap}) {
    return IconButton(
      icon: Icon(Icons.map_rounded, color: color),
      onPressed: onTap,
      tooltip: 'Pilih dari peta',
    );
  }

  Widget _buildPaymentChip(String label, IconData icon, bool isDark) {
    final selected = paymentMethod.value == label;
    return GestureDetector(
      onTap: () => paymentMethod.value = label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4F46E5)
              : (isDark ? const Color(0xFF374151) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF4F46E5)
                : (isDark ? Colors.white24 : Colors.grey.shade200),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order, int idx, bool isDark) {
    final statusColor = _getStatusColor(order.status);
    final stepIdx = _BuyerStatusConfig.indexOf(order.status);

    return _PressableCard(
      onTap: () => Get.bottomSheet(
        OrderDetailSheet(order: order),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header baris atas ────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_BuyerStatusConfig.iconOf(order.status),
                        color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.itemName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _infoRow(Icons.storefront_outlined,
                            order.location, Colors.grey),
                        const SizedBox(height: 3),
                        _infoRow(Icons.flag_rounded,
                            order.destinationLocation, Colors.redAccent),
                      ],
                    ),
                  ),
                  // Status badge + harga
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _BuyerStatusConfig.labelOf(order.status),
                          style: GoogleFonts.poppins(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(double.tryParse(order.deliveryFee.toString()) ?? 0)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── STATUS STEPPER ────────────────────────────────────
              _buildBuyerStepper(stepIdx, isDark),

              // ── Driver info (jika sudah ada driver) ───────────────
              if (order.status != 'pending' && order.status != 'cancelled') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFF10B981).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.electric_moped_rounded,
                            color: Color(0xFF10B981), size: 16),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Driver sedang menangani pesananmu',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF10B981),
                                  fontWeight: FontWeight.w600)),
                          Text(
                            _getBuyerStatusMessage(order.status),
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // ── Payment chip ──────────────────────────────────────
              const SizedBox(height: 10),
              Row(
                children: [
                  _statusChip(order.paymentMethod, Colors.blue),
                  const Spacer(),
                  // Edit & delete hanya saat pending
                  if (order.status == 'pending') ...[
                    _iconActionBtn(Icons.edit_rounded, Colors.blue,
                        () => _showEditDialog(context, order)),
                    const SizedBox(width: 8),
                    _iconActionBtn(Icons.delete_rounded, Colors.redAccent,
                        () => orderController.deleteOrder(order.id)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fade(delay: (idx * 80 + 400).ms)
        .slideY(begin: 0.15, end: 0, delay: (idx * 80 + 400).ms);
  }

  // ── STATUS STEPPER untuk Pembeli ─────────────────────────────────────────
  Widget _buildBuyerStepper(int currentStep, bool isDark) {
    const steps = _BuyerStatusConfig.steps;
    const labels = _BuyerStatusConfig.labels;
    const icons = _BuyerStatusConfig.icons;
    const colors = _BuyerStatusConfig.colors;

    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i <= currentStep;
        final isCurrent = i == currentStep;
        final color = isActive ? colors[i] : Colors.grey.shade300;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      width: isCurrent ? 36 : 28,
                      height: isCurrent ? 36 : 28,
                      decoration: BoxDecoration(
                        color: isActive ? color : Colors.transparent,
                        border: Border.all(
                          color: isActive ? color : Colors.grey.shade300,
                          width: isCurrent ? 2.5 : 1.5,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                )
                              ]
                            : [],
                      ),
                      child: Icon(
                        icons[i],
                        size: isCurrent ? 17 : 13,
                        color: isActive
                            ? Colors.white
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i],
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isActive
                            ? color
                            : (isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (i < steps.length - 1)
                Expanded(
                  flex: 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: i < currentStep
                          ? LinearGradient(colors: [colors[i], colors[i + 1]])
                          : null,
                      color: i >= currentStep ? Colors.grey.shade300 : null,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  String _getBuyerStatusMessage(String status) {
    switch (status) {
      case 'accepted':   return 'Driver sedang menuju toko/restoran';
      case 'picked_up':  return 'Barang sudah diambil, dalam perjalanan ke kamu';
      case 'completed':  return 'Pesanan telah sampai di tujuan ✓';
      default:           return '';
    }
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
            color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _iconActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF4F46E5).withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded,
                size: 56, color: const Color(0xFF4F46E5).withOpacity(0.3)),
            const SizedBox(height: 12),
            Text('Belum ada pesanan aktif',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: const Color(0xFF4F46E5).withOpacity(0.7),
                )),
            const SizedBox(height: 6),
            Text('Buat titipan pertama kamu di atas!',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
      ).animate().fade(),
    );
  }

  void _showEditDialog(BuildContext context, order) {
    final editItemController = TextEditingController(text: order.itemName);
    final editPickupController = TextEditingController(text: order.location);
    final editDestController =
        TextEditingController(text: order.destinationLocation);

    Get.defaultDialog(
      title: 'Edit Pesanan',
      content: Column(children: [
        TextField(
            controller: editItemController,
            decoration: const InputDecoration(labelText: 'Barang')),
        const SizedBox(height: 8),
        TextField(
            controller: editPickupController,
            decoration: const InputDecoration(labelText: 'Lokasi Ambil')),
        const SizedBox(height: 8),
        TextField(
            controller: editDestController,
            decoration: const InputDecoration(labelText: 'Lokasi Antar')),
      ]),
      textConfirm: 'Simpan',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (editItemController.text.trim().isEmpty || 
            editPickupController.text.trim().isEmpty || 
            editDestController.text.trim().isEmpty) {
          Get.snackbar('Perhatian', 'Semua kolom harus diisi', backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }
        orderController.updateOrder(order.id, editItemController.text.trim(),
            editPickupController.text.trim(), editDestController.text.trim());
        Get.back();
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'accepted':
      case 'picked_up':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}

// ── Helper: Pressable card with scale animation ─────────────────────────────
class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressableCard({required this.child, required this.onTap});

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}
