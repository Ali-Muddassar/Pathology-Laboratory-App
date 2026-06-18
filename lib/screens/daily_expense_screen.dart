import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../models/data_notifier.dart';

class DailyExpenseScreen extends StatefulWidget {
  const DailyExpenseScreen({super.key});

  @override
  State<DailyExpenseScreen> createState() => _DailyExpenseScreenState();
}

class _DailyExpenseScreenState extends State<DailyExpenseScreen> {
  double get _totalExpenses {
    return ExpenseData.expenses.fold(0, (sum, e) => sum + e.amount);
  }

  void _addExpense() {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(ctx).brightness == Brightness.dark
                  ? Colors.grey.shade900
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 4,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Expense',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Amount (Rs) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final desc = descCtrl.text.trim();
                      final amount = double.tryParse(amountCtrl.text);
                      if (desc.isEmpty || amount == null || amount <= 0) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter valid description and amount.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      final expense = Expense(
                        id: DateTime.now().millisecondsSinceEpoch,
                        description: desc,
                        amount: amount,
                        date: DateTime.now(),
                      );
                      // Update static list
                      ExpenseData.expenses.add(expense);
                      DataNotifier.notify(); // notify dashboard
                      // Close dialog and then rebuild the screen
                      Navigator.pop(ctx);
                      // Force rebuild of this screen
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save Expense',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expenses = ExpenseData.expenses;

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Expenses', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: expenses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.money_off, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('No expenses recorded.', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      Text('Tap + to add your first expense.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      margin: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF6366F1).withOpacity(0.15),
                              const Color(0xFF8B5CF6).withOpacity(0.15),
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Total Expenses',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rs ${_totalExpenses.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${expenses.length} entries',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.money_off, color: Color(0xFFEF4444)),
                              ),
                              title: Text(
                                expense.description,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                '${DateFormat('dd MMM yyyy, hh:mm a').format(expense.date)}',
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                              ),
                              trailing: Text(
                                'Rs ${expense.amount.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
      ),
    );
  }
}
