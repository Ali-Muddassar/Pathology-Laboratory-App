class Order {
  final int id;
  final String orderId;
  final String patientName;
  final List<String> testNames;
  final double totalAmount;
  final double discount;
  final String status;
  final String paymentStatus;
  final DateTime orderDate;
  final Map<String, String> results;
  final String? referredBy; // <-- new

  Order({
    required this.id,
    required this.orderId,
    required this.patientName,
    required this.testNames,
    required this.totalAmount,
    required this.discount,
    required this.status,
    required this.paymentStatus,
    required this.orderDate,
    this.results = const {},
    this.referredBy,
  });

  Order copyWith({
    int? id,
    String? orderId,
    String? patientName,
    List<String>? testNames,
    double? totalAmount,
    double? discount,
    String? status,
    String? paymentStatus,
    DateTime? orderDate,
    Map<String, String>? results,
    String? referredBy,
  }) {
    return Order(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      patientName: patientName ?? this.patientName,
      testNames: testNames ?? this.testNames,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderDate: orderDate ?? this.orderDate,
      results: results ?? this.results,
      referredBy: referredBy ?? this.referredBy,
    );
  }
}

class OrderData {
  static List<Order> orders = [];
}