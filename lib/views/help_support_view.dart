import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Bantuan & Dukungan', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.help_outline, size: 60, color: Color(0xFF4F46E5)),
              ),
            ).animate().fade().scale(delay: 100.ms),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Ada yang bisa kami bantu?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ).animate().fade().slideY(begin: 0.2, delay: 200.ms),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Temukan jawaban dari pertanyaan yang sering diajukan di bawah ini.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
            ).animate().fade().slideY(begin: 0.2, delay: 300.ms),
            const SizedBox(height: 32),
            const Text('Pertanyaan Umum (FAQ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            _buildFAQItem(
              question: 'Bagaimana cara mengubah mode ke Driver?',
              answer: 'Anda bisa pergi ke halaman profil, lalu menekan tombol *switch* pada "Mode Pengguna" untuk beralih antara Pembeli dan Driver.',
              delay: 400,
            ),
            const SizedBox(height: 12),
            _buildFAQItem(
              question: 'Bagaimana cara melacak pesanan saya?',
              answer: 'Anda dapat melihat status pesanan aktif Anda langsung di Beranda atau melalui halaman Riwayat Pesanan.',
              delay: 500,
            ),
            const SizedBox(height: 12),
            _buildFAQItem(
              question: 'Metode pembayaran apa yang tersedia?',
              answer: 'Saat ini kami mendukung pembayaran tunai saat barang diterima (COD) dan beberapa metode transfer bank lokal.',
              delay: 600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer, required int delay}) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xFF4F46E5),
          collapsedIconColor: Colors.grey.shade600,
          title: Text(
            question,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(Get.context!).textTheme.bodyLarge?.color),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                answer,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade().slideY(begin: 0.2, delay: delay.ms);
  }

}
