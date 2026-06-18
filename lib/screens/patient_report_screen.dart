import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../models/order_model.dart';
import '../services/pdf_service.dart';

class PatientReportScreen extends StatefulWidget {
  const PatientReportScreen({super.key});

  @override
  State<PatientReportScreen> createState() => _PatientReportScreenState();
}

class _PatientReportScreenState extends State<PatientReportScreen> {
  bool _isGenerating = false;
  bool _isViewing = false;
  String _selectedPageSize = 'A4';

  @override
  void initState() {
    super.initState();
    _loadPageSize();
  }

  Future<void> _loadPageSize() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getString(PdfService.pageSizeKey) ?? 'A4';
    setState(() => _selectedPageSize = size);
  }

  List<Order> get _completedOrdersWithResults {
    final orders = OrderData.orders
        .where((order) => order.status == 'completed' && order.results.isNotEmpty)
        .toList();
    orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return orders;
  }

  Future<void> _viewReport(Order order) async {
    setState(() => _isViewing = true);
    try {
      final Uint8List pdfBytes = await PdfService.generateReportBytes(order);
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Report_${order.orderId}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error viewing report: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isViewing = false);
  }

  Future<void> _downloadReport(Order order) async {
    setState(() => _isGenerating = true);
    try {
      final filePath = await PdfService.generateReport(order);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report saved: $filePath'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving report: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    final orders = _completedOrdersWithResults;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Reports', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFEF4444),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: const Color(0xFFEF4444), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Page Size:',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: _selectedPageSize,
                  items: ['A4', 'A5', 'Letter'].map((size) {
                    return DropdownMenuItem(
                      value: size,
                      child: Text(size, style: GoogleFonts.poppins(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() => _selectedPageSize = value);
                      await PdfService.savePageSize(value);
                    }
                  },
                  underline: Container(),
                  icon: const Icon(Icons.arrow_drop_down),
                ),
              ],
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No reports available.', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Text('Complete orders with results to generate reports.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444), size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(order.orderId, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('Patient: ${order.patientName}', style: GoogleFonts.poppins(fontSize: 14)),
                                    if (order.referredBy != null)
                                      Text('Ref Dr: ${order.referredBy}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
                                    Text(
                                      '${order.results.length} results • ${order.orderDate.toLocal().toString().split(' ')[0]}',
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.blue),
                                onPressed: _isViewing ? null : () => _viewReport(order),
                                tooltip: 'View PDF',
                              ),
                              ElevatedButton.icon(
                                onPressed: _isGenerating ? null : () => _downloadReport(order),
                                icon: _isGenerating
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.download, color: Colors.white, size: 18),
                                label: Text(_isGenerating ? '...' : 'PDF'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? Colors.grey.shade700 : const Color(0xFFEF4444),
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
          ),
        ],
      ),
    );
  }
}