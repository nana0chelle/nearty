import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final isDriver = appController.isDriverMode.value;

      var completedOrders = isDriver
          ? orderController.driverHistoryOrders
              .where((o) => o.status == 'completed' || o.status == 'cancelled')
              .toList()
          : orderController.myOrders
              .where((o) => o.status == 'completed' || o.status == 'cancelled')
              .toList();

      return ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── HEADER ──────────────────────────────────────────────────
          _buildHeader(isDriver, isDark),

          // ── CONTENT ─────────────────────────────────────────────────
          if (completedOrders.isEmpty)
            _buildEmptyState(isDark)
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                children: completedOrders.asMap().entries.map((entry) {
                  return _buildHistoryCard(
                      entry.value, entry.key, isDriver, isDark, context);
                }).toList(),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildHeader(bool isDriver, bool isDark) {
    final gradColors = isDriver
        ? [const Color(0xFF059669), const Color(0xFF10B981)]
        : [const Color(0xFF4F46E5), const Color(0xFF7C3AED)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
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
                child: const Icon(Icons.history_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isDriver ? 'Mode Driver' : 'Mode Pembeli',
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 13)),
                  Text('Riwayat Pesanan',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ],
              ),
            ],
          ).animate().fade().slideY(begin: 0.3, end: 0),
          const SizedBox(height: 10),
          Text(
            isDriver
                ? 'Semua titipan yang sudah kamu antar'
                : 'Semua pesanan yang sudah selesai',
            style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.85), fontSize: 13),
          ).animate().fade(delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(dynamic order, int idx, bool isDriver,
      bool isDark, BuildContext context) {
    final isCompleted = order.status == 'completed';
    final statusColor =
        isCompleted ? const Color(0xFF10B981) : Colors.redAccent;

    return GestureDetector(
      onTap: () => Get.bottomSheet(
        OrderDetailSheet(order: order),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      ),
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ───────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: statusColor,
                        size: 22,
                      ),
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
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.storefront_outlined,
                                  size: 13, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  order.location,
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey.shade500,
                                      fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (order.completedAt != null) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 13, color: Colors.grey.shade400),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('d MMM y, HH:mm')
                                      .format(order.completedAt!),
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey.shade400,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(order.deliveryFee)}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isCompleted ? 'SELESAI' : 'DIBATALKAN',
                            style: GoogleFonts.poppins(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            order.paymentMethod,
                            style: GoogleFonts.poppins(
                              color: Colors.blue.shade700,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Ulasan section ────────────────────────────────────
                if (isCompleted) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  if (order.isReviewed)
                    _buildReviewDisplay(order, isDark)
                  else if (!isDriver)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.bottomSheet(
                            ReviewDialog(order: order),
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                          );
                        },
                        icon: const Icon(Icons.star_outline_rounded, size: 18),
                        label: Text('Beri Ulasan',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.amber.shade700,
                          side: BorderSide(
                              color: Colors.amber.shade600, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Text('Belum ada ulasan dari pembeli.',
                          style: GoogleFonts.poppins(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                              fontStyle: FontStyle.italic)),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fade(delay: (idx * 80).ms)
        .slideY(begin: 0.15, end: 0, delay: (idx * 80).ms);
  }

  // ── Tampilan ulasan lengkap (bintang + komentar) ──────────────────────────
  Widget _buildReviewDisplay(dynamic order, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  i < (order.rating ?? 0)
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${order.rating}/5',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          if (order.reviewComment != null &&
              order.reviewComment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.format_quote_rounded,
                    color: Colors.amber.shade400, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.reviewComment!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 6),
            Text('Tidak ada komentar.',
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.history_toggle_off_rounded,
                size: 64,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Riwayat Kosong',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.white70 : Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('Belum ada riwayat pesanan yang selesai.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade400, fontSize: 13)),
          ],
        ),
      ).animate().fade(),
    );
  }
}
