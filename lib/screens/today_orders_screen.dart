import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/order_model.dart';

class TodayOrdersScreen extends StatelessWidget {
  const TodayOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayOrders = OrderData.orders.where((order) {
      final orderDate = DateTime(order.orderDate.year, order.orderDate.month, order.orderDate.day);
      return orderDate == today;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Orders", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: todayOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.today, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No orders today.', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text('Create a new order from the Dashboard.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: todayOrders.length,
              itemBuilder: (context, index) {
                final order = todayOrders[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.orderId,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: order.status == 'completed' ? Colors.green.shade100 : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: TextStyle(
                                  color: order.status == 'completed' ? Colors.green.shade800 : Colors.orange.shade800,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Patient: ${order.patientName}', style: GoogleFonts.poppins(fontSize: 15)),
                        Text(
                          'Tests: ${order.testNames.join(', ')}',
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total: Rs ${order.totalAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: order.paymentStatus == 'paid' ? Colors.green.shade100 : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order.paymentStatus == 'paid' ? 'PAID' : 'UNPAID',
                                style: TextStyle(
                                  color: order.paymentStatus == 'paid' ? Colors.green.shade800 : Colors.red.shade800,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ordered at: ${_formatTime(order.orderDate)}',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}