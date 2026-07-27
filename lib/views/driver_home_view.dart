import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/order_controller.dart';
import '../widgets/order_detail_sheet.dart';
import '../widgets/animated_pressable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ── Status helper ────────────────────────────────────────────────────────────
class _StatusConfig {
  static const steps = ['pending', 'accepted', 'picked_up', 'completed'];
  static const labels = ['Menunggu', 'Diambil', 'Diantarkan', 'Selesai'];
  static const icons = [
    Icons.schedule_rounded,
    Icons.inventory_2_rounded,
    Icons.delivery_dining_rounded,
    Icons.check_circle_rounded,
  ];
  static const colors = [
    Color(0xFFF59E0B),
    Color(0xFF4F46E5),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
  ];

  static int indexOf(String status) => steps.indexOf(status).clamp(0, 3);
  static Color colorOf(String status) => colors[indexOf(status)];
  static IconData iconOf(String status) => icons[indexOf(status)];
  static String labelOf(String status) => labels[indexOf(status)];

  static String? nextStatus(String status) {
    final idx = steps.indexOf(status);
    if (idx < 0 || idx >= steps.length - 1) return null;
    return steps[idx + 1];
  }

  static String nextActionLabel(String status) {
    switch (status) {
      case 'accepted':  return 'Barang Sudah Diambil';
      case 'picked_up': return 'Tandai Selesai';
      default:          return '';
    }
  }

  static IconData nextActionIcon(String status) {
    switch (status) {
      case 'accepted':  return Icons.inventory_2_rounded;
      case 'picked_up': return Icons.check_circle_rounded;
      default:          return Icons.arrow_forward;
    }
  }
}

class DriverHomeView extends StatefulWidget {
  @override
  _DriverHomeViewState createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends State<DriverHomeView>
    with SingleTickerProviderStateMixin {
  bool isOnline = false;
  final OrderController orderController = Get.put(OrderController());
  late AnimationController _pulseController;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RefreshIndicator(
      onRefresh: () async {
        await orderController.fetchAvailableOrders();
        await orderController.fetchDriverActiveOrders();
      },
      color: const Color(0xFF10B981),
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // ── HEADER ─────────────────────────────────────────────────────
        _buildHeader(isDark),

        // ── ONLINE TOGGLE ──────────────────────────────────────────────
        Transform.translate(
          offset: const Offset(0, -24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildOnlineToggle(isDark),
          ),
        ),

        // ── AVAILABLE ORDERS ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Titipan Tersedia',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1F2937))),
              if (isOnline)
                Obx(() {
                  final cnt = orderController.availableOrders
                      .where((o) => o.status == 'pending')
                      .length;
                  return _badge('$cnt tersedia',
                      cnt > 0 ? const Color(0xFF10B981) : Colors.grey);
                }),
            ],
          ),
        ).animate().fade(delay: 300.ms),

        isOnline
            ? Obx(() {
                final pending = orderController.availableOrders
                    .where((o) => o.status == 'pending')
                    .toList();
                if (pending.isEmpty) {
                  return _emptyState(
                    icon: Icons.search_rounded,
                    msg: 'Tidak ada titipan tersedia.',
                    sub: 'Tetap online untuk menerima pesanan baru.',
                    color: const Color(0xFF10B981),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: pending.asMap().entries.map((e) {
                      return _buildAvailableCard(e.value, e.key, isDark);
                    }).toList(),
                  ),
                );
              })
            : _emptyState(
                icon: Icons.power_settings_new_rounded,
                msg: 'Kamu sedang offline.',
                sub: 'Aktifkan status untuk mulai menerima titipan.',
                color: Colors.grey,
              ),

        const SizedBox(height: 24),

        // ── ACTIVE ORDERS (dengan status stepper) ─────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pesanan Aktif Saya',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1F2937))),
              Obx(() => _badge(
                  '${orderController.driverOrders.length} aktif',
                  const Color(0xFF4F46E5))),
            ],
          ),
        ).animate().fade(delay: 400.ms),

        Obx(() {
          if (orderController.driverOrders.isEmpty) {
            return _emptyState(
              icon: Icons.delivery_dining_rounded,
              msg: 'Belum ada pesanan diambil.',
              sub: 'Ambil order dari daftar tersedia di atas.',
              color: const Color(0xFF4F46E5),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: orderController.driverOrders.asMap().entries.map((e) {
                return _buildActiveCard(e.value, e.key, isDark);
              }).toList(),
            ),
          );
        }),

        const SizedBox(height: 40),
      ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
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
                      color: Colors.white, shape: BoxShape.circle),
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
                    child: const Icon(Icons.electric_moped_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mode Driver',
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 13)),
                      Text('Halo, Driver! 🛵',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ],
                  ),
                ],
              ).animate().fade().slideY(begin: 0.3, end: 0),
              const SizedBox(height: 12),
              Text('Siap ambil titipan hari ini?\nSemangat pejuang rupiah! 💪',
                  style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  // ── ONLINE TOGGLE ─────────────────────────────────────────────────────────
  Widget _buildOnlineToggle(bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isOnline = !isOnline;
          if (isOnline) orderController.fetchAvailableOrders();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isOnline
                ? [const Color(0xFF059669), const Color(0xFF10B981)]
                : (isDark
                    ? [const Color(0xFF374151), const Color(0xFF4B5563)]
                    : [Colors.grey.shade200, Colors.grey.shade300]),
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isOnline
                  ? const Color(0xFF10B981).withOpacity(0.35)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isOnline
                        ? Colors.white.withOpacity(0.25)
                        : (isDark ? Colors.black26 : Colors.white),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) =>
                        RotationTransition(turns: anim, child: child),
                    child: Icon(
                      isOnline
                          ? Icons.electric_moped_rounded
                          : Icons.power_settings_new_rounded,
                      key: ValueKey(isOnline),
                      color: isOnline
                          ? Colors.white
                          : (isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        isOnline ? 'Online' : 'Offline',
                        key: ValueKey(isOnline),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isOnline
                              ? Colors.white
                              : (isDark
                                  ? Colors.white70
                                  : Colors.grey.shade700),
                        ),
                      ),
                    ),
                    Text(
                      isOnline
                          ? 'Mencari pesanan di sekitar...'
                          : 'Ketuk untuk mulai menerima',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isOnline
                            ? Colors.white.withOpacity(0.85)
                            : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 52,
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isOnline
                    ? Colors.white.withOpacity(0.3)
                    : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment:
                    isOnline ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ],
        ),
      ).animate().fade(delay: 150.ms).scale(begin: const Offset(0.95, 0.95)),
    );
  }

  // ── AVAILABLE ORDER CARD ──────────────────────────────────────────────────
  Widget _buildAvailableCard(dynamic order, int idx, bool isDark) {
    return _PressableCard(
      onTap: () => Get.bottomSheet(OrderDetailSheet(order: order),
          isScrollControlled: true, backgroundColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.shopping_bag_rounded,
                        color: Colors.amber.shade700, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.itemName,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937))),
                        const SizedBox(height: 6),
                        _row(Icons.person_outline, order.pembeliName,
                            Colors.grey),
                        const SizedBox(height: 4),
                        _row(Icons.location_on_outlined, order.location,
                            Colors.redAccent),
                        const SizedBox(height: 4),
                        _row(Icons.home_outlined, order.destinationLocation,
                            const Color(0xFF10B981)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(order.paymentMethod,
                              style: GoogleFonts.poppins(
                                  color: Colors.blue.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Potensi Untung',
                          style: GoogleFonts.poppins(
                              color: Colors.grey, fontSize: 11)),
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(double.tryParse(order.deliveryFee.toString()) ?? 0)}',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF10B981),
                            fontSize: 18),
                      ),
                    ],
                  ),
                  AnimatedPressable(
                    child: ElevatedButton.icon(
                      onPressed: () => orderController.acceptOrder(order),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: Text('Ambil',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fade(delay: (idx * 80).ms)
        .slideY(begin: 0.2, end: 0, delay: (idx * 80).ms);
  }

  // ── ACTIVE ORDER CARD WITH STATUS STEPPER ─────────────────────────────────
  Widget _buildActiveCard(dynamic order, int idx, bool isDark) {
    final statusColor = _StatusConfig.colorOf(order.status);
    final stepIdx = _StatusConfig.indexOf(order.status);
    final nextStatus = _StatusConfig.nextStatus(order.status);

    return _PressableCard(
      onTap: () => Get.bottomSheet(OrderDetailSheet(order: order),
          isScrollControlled: true, backgroundColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.1),
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
              // ── Order header ──────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_StatusConfig.iconOf(order.status),
                        color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.itemName,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937))),
                        const SizedBox(height: 4),
                        _row(Icons.person_outline, order.pembeliName,
                            Colors.grey),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _StatusConfig.labelOf(order.status),
                      style: GoogleFonts.poppins(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── STATUS STEPPER ────────────────────────────────────
              _buildStatusStepper(stepIdx, isDark),

              const SizedBox(height: 16),

              // ── Route info ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _row(Icons.location_on_rounded, 'Ambil: ${order.location}',
                        Colors.redAccent),
                    const SizedBox(height: 6),
                    _row(Icons.flag_rounded,
                        'Antar: ${order.destinationLocation}',
                        const Color(0xFF10B981)),
                  ],
                ),
              ),

              // ── Action button ─────────────────────────────────────
              if (nextStatus != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: AnimatedPressable(
                    child: ElevatedButton.icon(
                      onPressed: () => _advanceStatus(order, nextStatus),
                      icon: Icon(_StatusConfig.nextActionIcon(order.status),
                          size: 18),
                      label: Text(
                        _StatusConfig.nextActionLabel(order.status),
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate()
        .fade(delay: (idx * 100).ms)
        .slideX(begin: -0.15, end: 0, delay: (idx * 100).ms);
  }

  // ── STATUS STEPPER WIDGET ─────────────────────────────────────────────────
  Widget _buildStatusStepper(int currentStep, bool isDark) {
    const steps = _StatusConfig.steps;
    const labels = _StatusConfig.labels;
    const icons = _StatusConfig.icons;
    const colors = _StatusConfig.colors;

    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i <= currentStep;
        final isCurrent = i == currentStep;
        final color = isActive ? colors[i] : Colors.grey.shade300;

        return Expanded(
          child: Row(
            children: [
              // Circle step indicator
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      width: isCurrent ? 38 : 30,
                      height: isCurrent ? 38 : 30,
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
                        size: isCurrent ? 18 : 14,
                        color: isActive ? Colors.white : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i],
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
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
              // Connector line
              if (i < steps.length - 1)
                Expanded(
                  flex: 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: i < currentStep
                          ? LinearGradient(
                              colors: [colors[i], colors[i + 1]],
                            )
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

  void _advanceStatus(dynamic order, String nextStatus) {
    final label = nextStatus == 'picked_up' ? 'Sudah mengambil barang?' : 'Pesanan sudah diantarkan?';
    final confirmLabel = nextStatus == 'picked_up' ? 'Ya, Sudah Diambil' : 'Ya, Selesaikan';

    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: label,
      textConfirm: confirmLabel,
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: _StatusConfig.colorOf(nextStatus),
      onConfirm: () {
        Get.back();
        if (nextStatus == 'picked_up') {
          orderController.pickupOrder(order);
        } else if (nextStatus == 'completed') {
          orderController.completeOrder(order);
        }
      },
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _row(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(text,
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade600, fontSize: 12),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String msg,
    required String sub,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 54, color: color.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(msg,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: color.withOpacity(0.7))),
            const SizedBox(height: 6),
            Text(sub,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
      ).animate().fade(),
    );
  }
}

// ── Pressable card ────────────────────────────────────────────────────────────
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
