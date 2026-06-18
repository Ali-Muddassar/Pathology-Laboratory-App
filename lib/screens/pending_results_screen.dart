import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/order_model.dart';
import 'results_entry_screen.dart';

class PendingResultsScreen extends StatefulWidget {
  const PendingResultsScreen({super.key});

  @override
  State<PendingResultsScreen> createState() => _PendingResultsScreenState();
}

class _PendingResultsScreenState extends State<PendingResultsScreen> {
  List<Order> _pendingOrders = [];

  @override
  void initState() {
    super.initState();
    _loadPendingOrders();
  }

  void _loadPendingOrders() {
    setState(() {
      _pendingOrders = OrderData.orders.where((o) => o.status == 'pending').toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Results', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFEF4444),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingOrders,
          ),
        ],
      ),
      body: _pendingOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('All caught up!', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text('No pending results.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingOrders.length,
              itemBuilder: (context, index) {
                final order = _pendingOrders[index];
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
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'PENDING',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
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
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResultsEntryScreen(order: order),
                              ),
                            ).then((_) => _loadPendingOrders());
                          },
                          icon: Icon(Icons.edit, size: 18, color: isDark ? Colors.white : Colors.white),
                          label: const Text('Enter Results'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.indigo.shade300 : const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
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