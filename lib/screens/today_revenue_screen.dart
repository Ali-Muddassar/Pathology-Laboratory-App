import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';

class TodayRevenueScreen extends StatefulWidget {
  const TodayRevenueScreen({super.key});

  @override
  State<TodayRevenueScreen> createState() => _TodayRevenueScreenState();
}

class _TodayRevenueScreenState extends State<TodayRevenueScreen> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final todayPaidOrders = OrderData.orders.where((order) {
      final orderDate = DateTime(order.orderDate.year, order.orderDate.month, order.orderDate.day);
      return orderDate == today && order.paymentStatus == 'paid';
    }).toList();
    
    final totalRevenue = todayPaidOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
    final orderCount = todayPaidOrders.length;
    final average = orderCount > 0 ? totalRevenue / orderCount : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Revenue", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF06B6D4),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: todayPaidOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.money_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No revenue today.', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text('Paid orders will appear here.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Revenue',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rs ${totalRevenue.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              label: 'Orders',
                              value: '$orderCount',
                              icon: Icons.receipt_long,
                            ),
                            _StatItem(
                              label: 'Average',
                              value: 'Rs ${average.toStringAsFixed(2)}',
                              icon: Icons.analytics,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // List Header
                Text(
                  'Paid Orders Today',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Order List
                ...todayPaidOrders.map((order) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.payment, color: Color(0xFF06B6D4)),
                      ),
                      title: Text(
                        order.orderId,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${order.patientName} • ${DateFormat('hh:mm a').format(order.orderDate)}',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      trailing: Text(
                        'Rs ${order.totalAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF06B6D4),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}

// StatItem widget
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}