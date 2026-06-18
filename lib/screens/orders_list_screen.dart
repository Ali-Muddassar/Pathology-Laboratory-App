import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/order_model.dart';
import 'results_entry_screen.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final orders = OrderData.orders;
    final sortedOrders = List.from(orders)
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));

    return Scaffold(
      appBar: AppBar(
        title: Text('Lab Orders', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: sortedOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('No orders yet.', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      Text('Create your first order from the Dashboard.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedOrders.length,
                  itemBuilder: (context, index) {
                    final order = sortedOrders[index];
                    final isCompleted = order.status == 'completed';
                    final hasResults = order.results.isNotEmpty;
                    final isPaid = order.paymentStatus == 'paid';

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order ID + Status
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
                                    color: isCompleted ? Colors.green.shade100 : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isCompleted ? 'COMPLETED' : 'PENDING',
                                    style: TextStyle(
                                      color: isCompleted ? Colors.green.shade800 : Colors.orange.shade800,
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
                            // Total Amount + Payment Status
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
                                    color: isPaid ? Colors.green.shade100 : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isPaid ? 'PAID' : 'UNPAID',
                                    style: TextStyle(
                                      color: isPaid ? Colors.green.shade800 : Colors.red.shade800,
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
                            if (hasResults) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Results entered',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            // Action row: View/Results, Payment Toggle, Status Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // View/Results button
                                TextButton.icon(
                                  onPressed: () {
                                    if (hasResults) {
                                      _showResultsDialog(context, order);
                                    } else if (isCompleted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('No results for this order.')),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ResultsEntryScreen(order: order),
                                        ),
                                      ).then((_) => _refresh());
                                    }
                                  },
                                  icon: Icon(hasResults ? Icons.visibility : Icons.edit, size: 18),
                                  label: Text(hasResults ? 'View Results' : (isCompleted ? 'No Results' : 'Enter Results')),
                                  style: TextButton.styleFrom(
                                    foregroundColor: hasResults ? Colors.blue : Colors.orange.shade700,
                                  ),
                                ),
                                // Payment toggle button
                                if (!isPaid)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _togglePaymentStatus(order);
                                    },
                                    icon: const Icon(Icons.payment, size: 18, color: Colors.white),
                                    label: const Text('Mark as Paid'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade700,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    ),
                                  )
                                else
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      _togglePaymentStatus(order);
                                    },
                                    icon: const Icon(Icons.undo, size: 18),
                                    label: const Text('Unmark Paid'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.grey.shade700,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    ),
                                  ),
                                // Status toggle button
                                ElevatedButton.icon(
                                  onPressed: () => _toggleOrderStatus(order),
                                  icon: Icon(
                                    isCompleted ? Icons.undo : Icons.check_circle,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    isCompleted ? 'Undo' : 'Complete',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isCompleted ? Colors.grey.shade600 : Colors.green.shade700,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        ),
      ),
    );
  }

  // ----- Payment Toggle -----
  void _togglePaymentStatus(Order order) {
    final newPaymentStatus = order.paymentStatus == 'paid' ? 'pending' : 'paid';
    final updatedOrder = order.copyWith(paymentStatus: newPaymentStatus);
    final index = OrderData.orders.indexOf(order);
    if (index != -1) {
      OrderData.orders[index] = updatedOrder;
    }
    _refresh();
  }

  // ----- Status Toggle -----
  void _toggleOrderStatus(Order order) {
    final newStatus = order.status == 'pending' ? 'completed' : 'pending';
    String newPaymentStatus = order.paymentStatus;
    if (newStatus == 'completed' && order.paymentStatus == 'pending') {
      newPaymentStatus = 'paid';
    } else if (newStatus == 'pending') {
      newPaymentStatus = 'pending';
    }
    final updatedOrder = order.copyWith(
      status: newStatus,
      paymentStatus: newPaymentStatus,
    );
    final index = OrderData.orders.indexOf(order);
    if (index != -1) {
      OrderData.orders[index] = updatedOrder;
    }
    _refresh();
  }

  // ----- View Results Dialog -----
  void _showResultsDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Results for ${order.orderId}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient: ${order.patientName}', style: GoogleFonts.poppins(fontSize: 14)),
              const SizedBox(height: 8),
              ...order.results.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text('${entry.key}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(entry.value.isEmpty ? 'Not entered' : entry.value),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}