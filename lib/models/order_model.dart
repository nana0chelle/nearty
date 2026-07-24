class Order {
  final int id;
  final String itemName;
  final String location;
  final String destinationLocation;
  final int deliveryFee;
  final int? driverId;
  final String pembeliName;
  String status; 
  DateTime? completedAt;
  bool isReviewed;
  int? rating;
  final String paymentMethod;
  final double? pickupLat;
  final double? pickupLng;
  final double? destLat;
  final double? destLng;

  Order({
    required this.id,
    required this.itemName,
    required this.location,
    required this.destinationLocation,
    required this.deliveryFee,
    this.driverId,
    required this.pembeliName,
    this.status = 'pending',
    this.completedAt,
    this.isReviewed = false,
    this.rating,
    this.paymentMethod = 'Cash',
    this.pickupLat,
    this.pickupLng,
    this.destLat,
    this.destLng,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      itemName: json['item_name'] ?? 'Unknown Item',
      location: json['pickup_location'] ?? 'Unknown Location',
      destinationLocation: json['destination_location'] ?? '-',
      deliveryFee: json['fee'] != null ? double.parse(json['fee'].toString()).toInt() : 0,
      driverId: json['driver_id'],
      pembeliName: 'User', // Currently API doesn't join users table for myOrders, so just fallback
      status: json['status'] ?? 'pending',
      completedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isReviewed: json['review'] != null,
      rating: json['review'] != null ? json['review']['rating'] : null,
      paymentMethod: json['payment_method'] ?? 'Cash',
      pickupLat: json['pickup_lat'] != null ? double.tryParse(json['pickup_lat'].toString()) : null,
      pickupLng: json['pickup_lng'] != null ? double.tryParse(json['pickup_lng'].toString()) : null,
      destLat: json['dest_lat'] != null ? double.tryParse(json['dest_lat'].toString()) : null,
      destLng: json['dest_lng'] != null ? double.tryParse(json['dest_lng'].toString()) : null,
    );
  }
}
