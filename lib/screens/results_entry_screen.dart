import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/order_model.dart';
import '../models/test_model.dart';
import 'test_catalog_screen.dart';

class ResultsEntryScreen extends StatefulWidget {
  final Order order;
  const ResultsEntryScreen({super.key, required this.order});

  @override
  State<ResultsEntryScreen> createState() => _ResultsEntryScreenState();
}

class _ResultsEntryScreenState extends State<ResultsEntryScreen> {
  late Map<String, TextEditingController> _controllers;
  late Map<String, String> _dropdownValues;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    _dropdownValues = {};
    _initializeFields();
  }

  void _initializeFields() {
    for (var testName in widget.order.testNames) {
      final test = [].firstWhere(
        (t) => t.name == testName,
        orElse: () => Test(
          name: testName,
          type: 'simple',
          price: 0,
          isQualitative: false,
          components: [],
        ),
      );
      if (test.type == 'simple') {
        if (test.isQualitative) {
          _dropdownValues[testName] = widget.order.results[testName] ?? '';
        } else {
          _controllers[testName] = TextEditingController(
            text: widget.order.results[testName] ?? '',
          );
        }
      } else {
        for (var comp in test.components) {
          final key = '${testName}_${comp.name}';
          if (comp.isQualitative) {
            _dropdownValues[key] = widget.order.results[key] ?? '';
          } else {
            _controllers[key] = TextEditingController(
              text: widget.order.results[key] ?? '',
            );
          }
        }
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveResults() async {
    setState(() => _isSaving = true);
    final results = <String, String>{};
    for (var entry in _controllers.entries) {
      results[entry.key] = entry.value.text.trim();
    }
    for (var entry in _dropdownValues.entries) {
      if (entry.value.isNotEmpty) {
        results[entry.key] = entry.value;
      }
    }
    final updatedOrder = widget.order.copyWith(
      status: 'completed',
      results: results,
    );
    final index = OrderData.orders.indexOf(widget.order);
    if (index != -1) {
      OrderData.orders[index] = updatedOrder;
    }
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Results saved and order completed!'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Results for ${widget.order.orderId}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order info card (premium)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [Colors.grey.shade900, Colors.grey.shade800]
                          : [Colors.white, const Color(0xFFF5F3FF)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.person, color: Color(0xFF6366F1), size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.order.patientName,
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Order ID: ${widget.order.orderId}',
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
                            ),
                            if (widget.order.referredBy != null)
                              Text(
                                'Ref Dr: ${widget.order.referredBy}',
                                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Results fields
                Text(
                  'Enter Results',
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ..._buildResultFields(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveResults,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Save & Complete Order',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResultFields() {
    final fields = <Widget>[];
    for (var testName in widget.order.testNames) {
      final test = [].firstWhere(
        (t) => t.name == testName,
        orElse: () => Test(
          name: testName,
          type: 'simple',
          price: 0,
          isQualitative: false,
          components: [],
        ),
      );
      if (test.type == 'simple') {
        fields.add(_buildField(testName, test));
      } else {
        fields.add(
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(testName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                ...test.components.map((comp) {
                  final key = '${testName}_${comp.name}';
                  if (comp.isQualitative) {
                    return _buildDropdown(key, comp.name, null);
                  } else {
                    return _buildTextField(key, comp.name, comp.unit ?? '');
                  }
                }).toList(),
              ],
            ),
          ),
        );
      }
    }
    return fields;
  }

  Widget _buildField(String testName, Test test) {
    if (test.isQualitative) {
      return _buildDropdown(testName, testName, 'Positive/Negative');
    } else {
      return _buildTextField(testName, testName, test.unit ?? '');
    }
  }

  Widget _buildTextField(String key, String label, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: '$label ($unit)',
          labelStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
        ),
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(fontSize: 16),
      ),
    );
  }

  Widget _buildDropdown(String key, String label, String? hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _dropdownValues[key]?.isEmpty ?? true ? null : _dropdownValues[key],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
        ),
        hint: Text(hint ?? 'Select', style: GoogleFonts.poppins()),
        items: const [
          DropdownMenuItem(value: 'Positive', child: Text('Positive')),
          DropdownMenuItem(value: 'Negative', child: Text('Negative')),
        ],
        onChanged: (value) {
          setState(() {
            _dropdownValues[key] = value ?? '';
          });
        },
        style: GoogleFonts.poppins(fontSize: 16),
      ),
    );
  }
}
