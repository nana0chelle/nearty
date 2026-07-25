import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/admin_controller.dart';
import '../login_view.dart';
import '../../widgets/animated_pressable.dart';

class AdminOverviewView extends StatefulWidget {
  @override
  State<AdminOverviewView> createState() => _AdminOverviewViewState();
}

class _AdminOverviewViewState extends State<AdminOverviewView>
    with SingleTickerProviderStateMixin {
  final AdminController adminController = Get.put(AdminController());
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

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Get.offAll(() => LoginView());
  }

  void _confirmLogout() {
    Get.defaultDialog(
      title: 'Keluar',
      middleText: 'Yakin ingin keluar dari Admin Panel?',
      textConfirm: 'Keluar',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      cancelTextColor: Colors.black87,
      onConfirm: () => _logout(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      if (adminController.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF4F46E5)),
              const SizedBox(height: 16),
              Text('Memuat data...', style: GoogleFonts.poppins(color: Colors.grey)),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: adminController.fetchDashboardData,
        color: const Color(0xFF4F46E5),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER BANNER ──────────────────────────────────────────
              _buildHeader(isDark),

              const SizedBox(height: 20),

              // ── STAT CARDS ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            index: 0,
                            title: 'Total Pengguna',
                            value: adminController.totalUsers.value.toString(),
                            icon: Icons.people_alt_rounded,
                            gradient: const [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            index: 1,
                            title: 'Total Pesanan',
                            value: adminController.totalOrders.value.toString(),
                            icon: Icons.receipt_long_rounded,
                            gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            index: 2,
                            title: 'Pesanan Aktif',
                            value: adminController.activeOrders.value.toString(),
                            icon: Icons.electric_moped_rounded,
                            gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            index: 3,
                            title: 'Total Pendapatan',
                            value: 'Rp ${NumberFormat('#,###', 'id_ID').format(adminController.totalRevenue.value)}',
                            icon: Icons.account_balance_wallet_rounded,
                            gradient: const [Color(0xFF4F46E5), Color(0xFF818CF8)],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── RECENT ORDERS ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pesanan Terbaru',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${adminController.recentOrders.length} pesanan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF4F46E5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 400.ms).slideX(begin: -0.1),

              const SizedBox(height: 12),
              _buildRecentOrdersList(isDark),
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
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Opacity(
                opacity: 0.08 + _pulseController.value * 0.05,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: 30,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Opacity(
                opacity: 0.06 + _pulseController.value * 0.04,
                child: Container(
                  width: 80,
                  height: 80,
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
                    child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Panel',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          'Selamat Datang! 👋',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedPressable(
                    child: IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Colors.white),
                      onPressed: _confirmLogout,
                      tooltip: 'Keluar',
                    ),
                  ),
                ],
              ).animate().fade().slideY(begin: 0.3, end: 0),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color.lerp(Colors.greenAccent, Colors.green, _pulseController.value),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.5), blurRadius: 6)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Platform aktif & berjalan normal',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ).animate().fade(delay: 150.ms).slideY(begin: 0.3, end: 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required int index,
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return AnimatedPressable(
      child: GestureDetector(
        onTap: () {
          // Ripple feedback on tap
          adminController.fetchDashboardData();
        },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withOpacity(0.85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      )
          .animate()
          .fade(delay: (index * 80 + 200).ms)
          .slideY(begin: 0.3, end: 0, delay: (index * 80 + 200).ms)
          .then()
          .shimmer(duration: 800.ms, color: Colors.white.withOpacity(0.1)),
    ));
  }

  Widget _buildRecentOrdersList(bool isDark) {
    if (adminController.recentOrders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Belum ada pesanan.',
                style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 15)),
          ],
        ),
      ).animate().fade();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: adminController.recentOrders.length,
        itemBuilder: (context, index) {
          final order = adminController.recentOrders[index];
          final status = order['status'] ?? 'unknown';
          final isCompleted = status == 'completed';
          final isCancelled = status == 'cancelled';
          final isPending = status == 'pending';

          Color statusColor = const Color(0xFFF59E0B);
          IconData statusIcon = Icons.pending_rounded;
          if (isCompleted) { statusColor = const Color(0xFF10B981); statusIcon = Icons.check_circle_rounded; }
          if (isCancelled) { statusColor = Colors.redAccent; statusIcon = Icons.cancel_rounded; }
          if (isPending)   { statusColor = const Color(0xFFF59E0B); statusIcon = Icons.schedule_rounded; }

          return _AnimatedOrderCard(
            delay: index * 80,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade100,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['item_name'] ?? 'Unknown Item',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          order['user'] != null ? order['user']['name'] : 'Pengguna tidak diketahui',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(double.tryParse(order['fee'].toString()) ?? 0)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Helper: card with press animation ──────────────────────────────────────
class _AnimatedOrderCard extends StatefulWidget {
  final Widget child;
  final int delay;
  const _AnimatedOrderCard({required this.child, required this.delay});

  @override
  State<_AnimatedOrderCard> createState() => _AnimatedOrderCardState();
}

class _AnimatedOrderCardState extends State<_AnimatedOrderCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: widget.child
            .animate()
            .fade(delay: widget.delay.ms)
            .slideY(begin: 0.15, end: 0, delay: widget.delay.ms),
      ),
    );
  }
}
