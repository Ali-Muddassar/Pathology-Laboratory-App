import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drift/drift.dart' as drift;
import '../providers/database_provider.dart';
import '../database/database.dart' show Test, AppDatabase;
import '../models/order_model.dart';
import '../models/data_notifier.dart';

class NewOrderScreen extends ConsumerStatefulWidget {
  const NewOrderScreen({super.key});

  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referredByController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  String _selectedGender = 'Male';
  
  List<Test> _selectedTests = [];
  bool _isPaid = false;
  bool _isButtonHovered = false;

  double get _subtotal {
    double sum = 0;
    for (var test in _selectedTests) {
      sum += test.price;
    }
    return sum;
  }

  double get _discount {
    return double.tryParse(_discountController.text) ?? 0.0;
  }

  double get _totalAmount {
    return (_subtotal - _discount).clamp(0.0, double.infinity);
  }

  void _toggleTest(Test test) {
    setState(() {
      if (_selectedTests.contains(test)) {
        _selectedTests.remove(test);
      } else {
        _selectedTests.add(test);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final db = ref.watch(databaseProvider);
    final testsStream = db.watchAllTests();

    return Scaffold(
      appBar: AppBar(
        title: Text('New Order', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Patient Information', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder()),
                          validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: const InputDecoration(labelText: 'Gender *', border: OutlineInputBorder()),
                          items: ['Male', 'Female', 'Other'].map((gender) {
                            return DropdownMenuItem(value: gender, child: Text(gender));
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedGender = value!),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _ageController,
                                decoration: const InputDecoration(labelText: 'Age (0-100)', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return null;
                                  final age = int.tryParse(value);
                                  if (age == null) return 'Invalid age';
                                  if (age < 0 || age > 100) return 'Age must be 0-100';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(labelText: 'Phone (03xxxxxxxxx)', border: OutlineInputBorder(), errorMaxLines: 2),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return null;
                                  if (!RegExp(r'^03\d{9}$').hasMatch(value)) {
                                    return 'Must start with 03 and have 11 digits';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _referredByController,
                          decoration: const InputDecoration(labelText: 'Referred By Doctor', border: OutlineInputBorder()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Test Selection
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Tests', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        StreamBuilder<List<Test>>(
                          stream: testsStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: '));
                            }
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final availableTests = snapshot.data!;
                            if (availableTests.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    'No tests found. Please add tests from Test Catalog first.',
                                    style: GoogleFonts.poppins(color: Colors.orange),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: availableTests.map((test) {
                                final isSelected = _selectedTests.contains(test);
                                return ChoiceChip(
                                  key: ValueKey('_'),
                                  label: Text(test.name),
                                  selected: isSelected,
                                  onSelected: (_) => _toggleTest(test),
                                  selectedColor: const Color(0xFF6366F1),
                                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_selectedTests.isNotEmpty) ...[
                          const Divider(),
                          Text('Selected Tests', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _selectedTests.length,
                            itemBuilder: (context, index) {
                              final test = _selectedTests[index];
                              return Card(
                                key: ValueKey('selected__'),
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  title: Text(test.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                                  subtitle: Text(
                                    test.type != 'simple'
                                        ? 'Panel:  components'
                                        : (test.isQualitative ? 'Qualitative' : 'Quantitative'),
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Rs ',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red, size: 20),
                                        onPressed: () => _toggleTest(test),
                                        tooltip: 'Remove',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Discount Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Discount', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _discountController,
                          decoration: const InputDecoration(
                            labelText: 'Discount Amount (Rs)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.discount),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            if (value == null || value.isEmpty) return null;
                            if (double.tryParse(value) == null) return 'Enter a valid number';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Total Amount Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.15),
                          const Color(0xFF6366F1).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.4), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal', style: GoogleFonts.poppins(fontSize: 16)),
                            Text('Rs ', style: GoogleFonts.poppins(fontSize: 16)),
                          ],
                        ),
                        if (_discount > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Discount', style: GoogleFonts.poppins(fontSize: 16, color: Colors.red)),
                              Text('- Rs ', style: GoogleFonts.poppins(fontSize: 16, color: Colors.red)),
                            ],
                          ),
                        ],
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                            Text(
                              'Rs ',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Status', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_isPaid ? 'Paid' : 'Pending', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _isPaid ? Colors.green : Colors.red)),
                            Switch(
                              value: _isPaid,
                              onChanged: (value) => setState(() => _isPaid = value),
                              activeColor: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Create Order Button
                  MouseRegion(
                    onEnter: (_) => setState(() => _isButtonHovered = true),
                    onExit: (_) => setState(() => _isButtonHovered = false),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() && _selectedTests.isNotEmpty) {
                            final discount = double.tryParse(_discountController.text) ?? 0.0;
                            final netAmount = (_subtotal - discount).clamp(0.0, double.infinity);
                            final order = Order(
                              id: DateTime.now().millisecondsSinceEpoch,
                              orderId: 'LAB--',
                              patientName: _nameController.text.trim(),
                              testNames: _selectedTests.map((t) => t.name).toList(),
                              totalAmount: netAmount,
                              discount: discount,
                              status: 'pending',
                              paymentStatus: _isPaid ? 'paid' : 'pending',
                              orderDate: DateTime.now(),
                              referredBy: _referredByController.text.trim().isNotEmpty ? _referredByController.text.trim() : null,
                            );
                            OrderData.orders.add(order);
                            DataNotifier.notify();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order Created Successfully!'), backgroundColor: Colors.green),
                            );
                            Navigator.pop(context);
                          } else if (_selectedTests.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select at least one test'), backgroundColor: Colors.orange),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isButtonHovered ? const Color(0xFF4F46E5) : const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Create Order',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
