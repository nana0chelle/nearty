import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/admin_controller.dart';

class AdminReviewsView extends StatefulWidget {
  @override
  _AdminReviewsViewState createState() => _AdminReviewsViewState();
}

class _AdminReviewsViewState extends State<AdminReviewsView> {
  final AdminController adminController = Get.find();

  @override
  void initState() {
    super.initState();
    adminController.fetchReviews();
  }

  void _confirmDelete(Map<String, dynamic> review) {
    Get.defaultDialog(
      title: 'Hapus Ulasan?',
      middleText: 'Yakin ingin menghapus ulasan ini?',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        adminController.deleteReview(review['id']);
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Kelola Ulasan', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4F46E5),
        centerTitle: true,
      ),
      body: Obx(() {
        if (adminController.isReviewsLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
        }

        if (adminController.reviews.isEmpty) {
          return const Center(child: Text('Tidak ada ulasan.'));
        }

        return RefreshIndicator(
          onRefresh: adminController.fetchReviews,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: adminController.reviews.length,
            itemBuilder: (context, index) {
              final review = adminController.reviews[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _confirmDelete(review),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review['comment'] ?? 'Tidak ada komentar',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pesanan ID: ${review['order_id']}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
