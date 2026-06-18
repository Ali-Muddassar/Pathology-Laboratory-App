import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<Map<String, dynamic>> _stockItems = [];
  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final stockJson = prefs.getString('stock_items') ?? '[]';
    final expensesJson = prefs.getString('expenses') ?? '[]';
    setState(() {
      _stockItems = List<Map<String, dynamic>>.from(json.decode(stockJson));
      _expenses = List<Map<String, dynamic>>.from(json.decode(expensesJson));
      _isLoading = false;
    });
  }

  Future<void> _saveStock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stock_items', json.encode(_stockItems));
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('expenses', json.encode(_expenses));
  }

  void _addStockItem() {
    final nameCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();
    final thresholdCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    DateTime? expiryDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: const Text('Add Stock Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Item Name*')),
                  TextField(controller: quantityCtrl, decoration: const InputDecoration(labelText: 'Quantity*'), keyboardType: TextInputType.number),
                  TextField(controller: thresholdCtrl, decoration: const InputDecoration(labelText: 'Low Stock Threshold'), keyboardType: TextInputType.number),
                  ListTile(
                    title: Text(expiryDate == null ? 'Select Expiry Date' : 'Expiry: '),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) {
                        setStateDialog(() => expiryDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;
                  final quantity = int.tryParse(quantityCtrl.text) ?? 0;
                  final threshold = int.tryParse(thresholdCtrl.text) ?? 5;
                  setState(() {
                    _stockItems.add({
                      'id': DateTime.now().millisecondsSinceEpoch,
                      'name': nameCtrl.text.trim(),
                      'quantity': quantity,
                      'threshold': threshold,
                      'expiry': expiryDate?.toIso8601String(),
                      'added': DateTime.now().toIso8601String(),
                    });
                    _saveStock();
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addExpense() {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description*')),
            TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Amount*'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (descCtrl.text.trim().isEmpty || amount == 0) return;
              setState(() {
                _expenses.add({
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'description': descCtrl.text.trim(),
                  'amount': amount,
                  'date': DateTime.now().toIso8601String(),
                });
                _saveExpenses();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      final newQty = _stockItems[index]['quantity'] + delta;
      if (newQty >= 0) {
        _stockItems[index]['quantity'] = newQty;
        _saveStock();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalExpenses = _expenses.fold(0.0, (sum, e) => sum + e['amount']);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Inventory & Stock', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory), text: 'Stock Items'),
              Tab(icon: Icon(Icons.receipt), text: 'Expenses'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Stock Items Tab
            Column(
              children: [
                Expanded(
                  child: _stockItems.isEmpty
                      ? const Center(child: Text('No stock items. Tap + to add.'))
                      : ListView.builder(
                          itemCount: _stockItems.length,
                          itemBuilder: (context, index) {
                            final item = _stockItems[index];
                            final isExpired = item['expiry'] != null && DateTime.parse(item['expiry']).isBefore(DateTime.now());
                            final isLowStock = item['quantity'] <= item['threshold'];
                            return Card(
                              margin: const EdgeInsets.all(8),
                              color: isExpired ? Colors.red.shade100 : (isLowStock ? Colors.orange.shade100 : null),
                              child: ListTile(
                                title: Text(item['name']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Quantity: '),
                                    if (item['expiry'] != null) Text('Expiry: '),
                                    if (isLowStock && !isExpired) Text('⚠️ Low stock!', style: const TextStyle(color: Colors.orange)),
                                    if (isExpired) Text('❌ EXPIRED!', style: const TextStyle(color: Colors.red)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(onPressed: () => _updateQuantity(index, -1), icon: const Icon(Icons.remove)),
                                    Text('', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    IconButton(onPressed: () => _updateQuantity(index, 1), icon: const Icon(Icons.add)),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _stockItems.removeAt(index);
                                          _saveStock();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton.icon(
                    onPressed: _addStockItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Stock Item'),
                  ),
                ),
              ],
            ),
            // Expenses Tab
            Column(
              children: [
                Expanded(
                  child: _expenses.isEmpty
                      ? const Center(child: Text('No expenses recorded. Tap + to add.'))
                      : ListView.builder(
                          itemCount: _expenses.length,
                          itemBuilder: (context, index) {
                            final exp = _expenses[index];
                            return ListTile(
                              leading: const Icon(Icons.money_off),
                              title: Text(exp['description']),
                              subtitle: Text(DateTime.parse(exp['date']).toLocal().toString().split(' ')[0]),
                              trailing: Text('₹', style: const TextStyle(fontWeight: FontWeight.bold)),
                            );
                          },
                        ),
                ),
                Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: const Text('Total Expenses'),
                    trailing: Text('₹', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton.icon(
                    onPressed: _addExpense,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expense'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
