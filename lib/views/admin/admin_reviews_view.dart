import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/admin_controller.dart';

class AdminReviewsView extends StatefulWidget {
  @override
  _AdminReviewsViewState createState() => _AdminReviewsViewState();
}

class _AdminReviewsViewState extends State<AdminReviewsView>
    with SingleTickerProviderStateMixin {
  final AdminController adminController = Get.put(AdminController());
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    adminController.fetchReviews();
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

  void _confirmDelete(Map<String, dynamic> review) {
    Get.defaultDialog(
      title: 'Hapus Ulasan?',
      middleText: 'Tindakan ini tidak dapat dibatalkan.',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        adminController.deleteReview(review['id']);
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      if (adminController.isReviewsLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF4F46E5)),
              const SizedBox(height: 16),
              Text('Memuat ulasan...',
                  style: GoogleFonts.poppins(color: Colors.grey)),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: adminController.fetchReviews,
        color: const Color(0xFF4F46E5),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER BANNER ──────────────────────────────────────
              _buildHeader(isDark),

              // ── STATS BAR ──────────────────────────────────────────
              if (adminController.reviews.isNotEmpty)
                _buildStatsBar(isDark),

              const SizedBox(height: 8),

              // ── REVIEW LIST ────────────────────────────────────────
              if (adminController.reviews.isEmpty)
                _buildEmptyState(isDark)
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: adminController.reviews
                        .asMap()
                        .entries
                        .map((entry) => _buildReviewCard(
                            entry.value, entry.key, isDark))
                        .toList(),
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 36),
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
                    child: const Icon(Icons.star_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin Panel',
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 13)),
                      Text('Manajemen Ulasan',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ],
                  ),
                ],
              ).animate().fade().slideY(begin: 0.3, end: 0),
              const SizedBox(height: 10),
              Text('Pantau & kelola semua ulasan dari pembeli',
                  style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(bool isDark) {
    final reviews = adminController.reviews;
    final totalRating = reviews.fold<double>(
        0, (sum, r) => sum + ((r['rating'] ?? 0) as num).toDouble());
    final avgRating =
        reviews.isEmpty ? 0.0 : totalRating / reviews.length;
    final withComment =
        reviews.where((r) => (r['comment'] ?? '').toString().isNotEmpty).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _miniStatCard(
              isDark: isDark,
              label: 'Total Ulasan',
              value: '${reviews.length}',
              icon: Icons.reviews_rounded,
              color: const Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _miniStatCard(
              isDark: isDark,
              label: 'Rata-rata',
              value: '${avgRating.toStringAsFixed(1)} ⭐',
              icon: Icons.star_rounded,
              color: Colors.amber.shade600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _miniStatCard(
              isDark: isDark,
              label: 'Ada Komentar',
              value: '$withComment',
              icon: Icons.chat_bubble_outline_rounded,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ).animate().fade(delay: 200.ms),
    );
  }

  Widget _miniStatCard({
    required bool isDark,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF1F2937))),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
      Map<String, dynamic> review, int idx, bool isDark) {
    final rating = (review['rating'] ?? 0) as num;
    final comment = review['comment'] ?? '';
    final hasComment = comment.toString().isNotEmpty;
    final buyerName = review['user'] != null
        ? review['user']['name']
        : (review['pembeli_name'] ?? 'Pembeli');
    final itemName = review['order'] != null
        ? review['order']['item_name']
        : 'Pesanan #${review['order_id']}';

    Color ratingColor;
    if (rating >= 4) {
      ratingColor = const Color(0xFF10B981);
    } else if (rating >= 3) {
      ratingColor = Colors.amber.shade700;
    } else {
      ratingColor = Colors.redAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ratingColor.withOpacity(0.7), ratingColor],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      buyerName.isNotEmpty
                          ? buyerName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(buyerName,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1F2937))),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.shopping_bag_outlined,
                              size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(itemName,
                                style: GoogleFonts.poppins(
                                    color: Colors.grey.shade400,
                                    fontSize: 12),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Rating badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: ratingColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded,
                          color: ratingColor, size: 14),
                      const SizedBox(width: 3),
                      Text('$rating',
                          style: GoogleFonts.poppins(
                              color: ratingColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Stars row ─────────────────────────────────────────
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < rating.toInt()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),

            // ── Comment ───────────────────────────────────────────
            if (hasComment) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? Colors.white12
                          : Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote_rounded,
                        color: Colors.grey.shade400, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        comment.toString(),
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
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text('Tidak ada komentar.',
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                      fontStyle: FontStyle.italic)),
            ],

            // ── Delete btn ────────────────────────────────────────
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pesanan #${review['order_id']}',
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade400, fontSize: 11),
                ),
                GestureDetector(
                  onTap: () => _confirmDelete(review),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.redAccent.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded,
                            color: Colors.redAccent, size: 14),
                        const SizedBox(width: 4),
                        Text('Hapus',
                            style: GoogleFonts.poppins(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fade(delay: (idx * 80).ms)
        .slideY(begin: 0.15, end: 0, delay: (idx * 80).ms);
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
            Icon(Icons.reviews_rounded,
                size: 64,
                color: isDark
                    ? Colors.grey.shade600
                    : Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Belum Ada Ulasan',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark
                        ? Colors.white70
                        : Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('Ulasan dari pembeli akan muncul di sini.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade400, fontSize: 13)),
          ],
        ),
      ).animate().fade(),
    );
  }
}
