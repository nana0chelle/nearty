import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../widgets/animated_pressable.dart';

class ReviewDialog extends StatefulWidget {
  final Order order;
  const ReviewDialog({required this.order, Key? key}) : super(key: key);

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  final OrderController orderController = Get.find<OrderController>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.rate_review_rounded,
                color: Colors.white, size: 32),
          ).animate().scale(begin: const Offset(0.7, 0.7)),

          const SizedBox(height: 20),

          Text(
            'Beri Penilaian',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ).animate().fade(delay: 100.ms),

          const SizedBox(height: 6),
          Text(
            '"${widget.order.itemName}"',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ).animate().fade(delay: 150.ms),

          const SizedBox(height: 28),

          // Star rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: index < _rating ? 46 : 40,
                    color: index < _rating ? Colors.amber : Colors.grey.shade400,
                  ),
                ),
              );
            }),
          ).animate().fade(delay: 200.ms),

          const SizedBox(height: 8),

          // Rating label
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _ratingLabel(_rating),
              key: ValueKey(_rating),
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _ratingColor(_rating),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Comment field
          TextField(
            controller: _commentController,
            maxLines: 3,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Tulis ulasan (opsional)...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 48),
                child: Icon(Icons.edit_note_rounded,
                    color: Colors.grey.shade400, size: 22),
              ),
            ),
          ).animate().fade(delay: 250.ms),

          const SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: AnimatedPressable(
              child: ElevatedButton.icon(
                onPressed: () {
                  orderController.submitReview(
                      widget.order.id, _rating, _commentController.text);
                  Get.back();
                  Get.snackbar(
                    'Berhasil',
                    'Terima kasih atas ulasanmu! ⭐',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF10B981),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text('Kirim Ulasan',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1: return '😞 Sangat Buruk';
      case 2: return '😕 Buruk';
      case 3: return '😐 Cukup';
      case 4: return '😊 Bagus';
      case 5: return '🤩 Sangat Bagus!';
      default: return '';
    }
  }

  Color _ratingColor(int r) {
    switch (r) {
      case 1: return Colors.redAccent;
      case 2: return Colors.orange;
      case 3: return Colors.amber.shade700;
      case 4: return const Color(0xFF10B981);
      case 5: return const Color(0xFF4F46E5);
      default: return Colors.grey;
    }
  }
}
