import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/database_provider.dart';
import '../providers/theme_provider.dart';
import '../database/database.dart';
import 'new_order_screen.dart';
import 'test_catalog_screen.dart';
import 'orders_list_screen.dart';
import 'patient_report_screen.dart';
import 'daily_expense_screen.dart';
import 'pending_results_screen.dart';
import 'today_revenue_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _todayOrders = 0;
  double _todayRevenue = 0;
  int _pendingResults = 0;
  double _totalExpenses = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = ref.read(databaseProvider);
    final todayOrders = await db.getTodayOrdersCount();
    final todayRevenue = await db.getTodayRevenue();
    final orders = await db.watchAllOrders().first;
    final pending = orders.where((o) => o.status == 'pending').length;
    final expenses = await db.getTotalExpenses();
    final tests = await db.watchAllTests().first;

    setState(() {
      _todayOrders = todayOrders;
      _todayRevenue = todayRevenue;
      _pendingResults = pending;
      _totalExpenses = expenses;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              theme == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              final newMode = theme == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
              ref.read(themeProvider.notifier).toggleTheme(newMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFD946EF)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back!',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Here\'s your lab performance summary',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Stats Grid - 4 cards per row on desktop
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 1000 ? 4 : constraints.maxWidth > 700 ? 3 : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          final cards = [
                            {'title': 'New Order', 'icon': Icons.add_shopping_cart, 'color': const Color(0xFF6366F1), 'screen': const NewOrderScreen()},
                            {'title': 'Lab Order', 'icon': Icons.receipt_long, 'color': const Color(0xFFF59E0B), 'screen': const OrdersListScreen()},
                            {'title': 'Test Catalog', 'icon': Icons.science, 'color': const Color(0xFF10B981), 'screen': const TestCatalogScreen()},
                            {'title': 'Patient Report', 'icon': Icons.picture_as_pdf, 'color': const Color(0xFFEF4444), 'screen': const PatientReportScreen()},
                            {'title': 'Today\'s Orders', 'value': '', 'icon': Icons.today, 'color': const Color(0xFF3B82F6), 'screen': const OrdersListScreen()},
                            {'title': 'Daily Expense', 'icon': Icons.money_off, 'color': const Color(0xFF8B5CF6), 'screen': const DailyExpenseScreen()},
                            {'title': 'Pending Results', 'value': '', 'icon': Icons.pending_actions, 'color': const Color(0xFFEF4444), 'screen': const PendingResultsScreen()},
                            {'title': 'Today\'s Revenue', 'value': '₹', 'icon': Icons.currency_rupee, 'color': const Color(0xFF06B6D4), 'screen': const TodayRevenueScreen()},
                          ];
                          final card = cards[index];
                          return _DashboardCard(
                            title: card['title'] as String,
                            value: card.containsKey('value') ? card['value'] as String : null,
                            icon: card['icon'] as IconData,
                            color: card['color'] as Color,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => card['screen'] as Widget),
                              ).then((_) => _loadData());
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Recent Orders Section
                  _buildRecentOrdersSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildRecentOrdersSection() {
    final db = ref.read(databaseProvider);
    
    return FutureBuilder<List<LabOrder>>(
      future: db.watchAllOrders().first,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data!.take(5).toList();
        
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Orders',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OrdersListScreen()),
                        );
                      },
                      child: const Text('View All →'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (orders.isEmpty)
                  const Center(child: Text('No orders yet')),
                ...orders.map((order) => FutureBuilder(
                  future: db.getPatient(order.patientId),
                  builder: (context, patientSnapshot) {
                    final patientName = patientSnapshot.hasData ? patientSnapshot.data!.name : 'Loading...';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: order.status == 'completed' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              order.status == 'completed' ? Icons.check_circle : Icons.pending,
                              color: order.status == 'completed' ? Colors.green : Colors.orange,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.orderId,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                Text(
                                  patientName,
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: order.paymentStatus == 'paid' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.paymentStatus == 'paid' ? 'Paid' : 'Pending',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: order.paymentStatus == 'paid' ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  },
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String? value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? [Colors.grey.shade900, Colors.grey.shade800]
                : [Colors.white, Colors.grey.shade50],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (value != null)
                    Text(
                      value!,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
