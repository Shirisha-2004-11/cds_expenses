import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ── Centralised theme tokens ─────────────────────────────────────────────────
// ignore: unused_import
import '../theme/dashboard_colors.dart';
// ignore: unused_import
import '../theme/dashboard_text_styles.dart';
// ignore: unused_import
import '../widgets/common/dashboard_filter_chip.dart';
// ignore: unused_import
import '../widgets/common/dashboard_period_picker_button.dart';
// ignore: unused_import
import '../widgets/common/dashboard_icon_box.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

class ExpenseItem {
  final String category;
  final String date;
  final String note;
  final int amount;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;

  const ExpenseItem({
    required this.category,
    required this.date,
    required this.note,
    required this.amount,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
  });
}

// ─── Sample Data (temporary — remove once backend is ready) ──────────────────

final List<ExpenseItem> _sampleExpenses = [
  ExpenseItem(
    category: 'Food',
    date: 'April 23',
    note: 'Lunch',
    amount: 450,
    iconBg: const Color(0xFFFFF3E0),
    iconColor: const Color(0xFFE67E22),
    icon: Icons.fastfood_rounded,
  ),
  ExpenseItem(
    category: 'Travel',
    date: 'April 23',
    note: 'Taxi fare',
    amount: 280,
    iconBg: const Color(0xFFE3F2FD),
    iconColor: const Color(0xFF2196F3),
    icon: Icons.directions_car_rounded,
  ),
  ExpenseItem(
    category: 'Health',
    date: 'April 21',
    note: 'Pharmacy',
    amount: 400,
    iconBg: const Color(0xFFE8F5E9),
    iconColor: const Color(0xFF4CAF50),
    icon: Icons.medication_rounded,
  ),
  ExpenseItem(
    category: 'Bills',
    date: 'April 21',
    note: 'Electricity bills',
    amount: 1200,
    iconBg: const Color(0xFFF3E5F5),
    iconColor: const Color(0xFF9C27B0),
    icon: Icons.receipt_long_rounded,
  ),
  ExpenseItem(
    category: 'Food',
    date: 'April 23',
    note: 'Lunch',
    amount: 450,
    iconBg: const Color(0xFFFFF3E0),
    iconColor: const Color(0xFFE67E22),
    icon: Icons.fastfood_rounded,
  ),
  ExpenseItem(
    category: 'Travel',
    date: 'April 23',
    note: 'Taxi fare',
    amount: 280,
    iconBg: const Color(0xFFE3F2FD),
    iconColor: const Color(0xFF2196F3),
    icon: Icons.directions_car_rounded,
  ),
  ExpenseItem(
    category: 'Health',
    date: 'April 21',
    note: 'Pharmacy',
    amount: 400,
    iconBg: const Color(0xFFE8F5E9),
    iconColor: const Color(0xFF4CAF50),
    icon: Icons.medication_rounded,
  ),
  ExpenseItem(
    category: 'Bills',
    date: 'April 21',
    note: 'Electricity bills',
    amount: 1200,
    iconBg: const Color(0xFFF3E5F5),
    iconColor: const Color(0xFF9C27B0),
    icon: Icons.receipt_long_rounded,
  ),
  ExpenseItem(
    category: 'Travel',
    date: 'April 23',
    note: 'Taxi fare',
    amount: 280,
    iconBg: const Color(0xFFE3F2FD),
    iconColor: const Color(0xFF2196F3),
    icon: Icons.directions_car_rounded,
  ),
];

// ─── Main Page ────────────────────────────────────────────────────────────────

class RecentExpensesPage extends StatefulWidget {
  const RecentExpensesPage({super.key});

  @override
  State<RecentExpensesPage> createState() => _RecentExpensesPageState();
}

class _RecentExpensesPageState extends State<RecentExpensesPage> {
  String _selectedFilter = 'All';
  String _selectedPeriod = 'Last 30 days';

  // ── CHANGE 1: replaced static _sampleExpenses with these two lines ──
  List<ExpenseItem> _expenses = [];
  bool _loading = true;

  final List<String> _filters = ['All', 'Food', 'Travel', 'Health', 'Bills'];

  // ── CHANGE 2: added initState + _loadExpenses ──
  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    // Temporary fake delay — replace this block with ExpenseService.getExpenses()
    // once your backend is ready:
    //   final data = await ExpenseService.getExpenses();
    //   setState(() { _expenses = data; _loading = false; });
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _expenses = _sampleExpenses;
      _loading = false;
    });
  }

  // ── CHANGE 3: getter now reads _expenses instead of _sampleExpenses ──
  List<ExpenseItem> get _filteredExpenses {
    if (_selectedFilter == 'All') return _expenses;
    return _expenses
        .where((e) => e.category == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              _buildFilterChips(),
              const SizedBox(height: 4),
              Expanded(child: _buildExpenseList()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left,
              size: 28,
              color: Color(0xFF1C1C1E),
            ),
            onPressed: () => Navigator.maybePop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          const Text(
            'Recent Expenses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B8A8A),
              letterSpacing: -0.3,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF0B8A8A),
              decorationThickness: 1.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showPeriodPicker,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFD0CEC8), width: 0.9),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedPeriod,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3C3C3E),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Color(0xFF3C3C3E),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Chips ───────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((label) {
            final isSelected = _selectedFilter == label;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0B8A8A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0B8A8A)
                        : const Color(0xFFD0CEC8),
                    width: 0.9,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF3C3C3E),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Expense List ───────────────────────────────────────────────────────────

  Widget _buildExpenseList() {
    // ── CHANGE 4: added loading spinner at the top ──
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0B8A8A)),
      );
    }

    // everything below is exactly the same as before
    final items = _filteredExpenses;

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No expenses found',
          style: TextStyle(color: Color(0xFF8A8A8E), fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) =>
          _ExpenseTile(item: items[index]),
    );
  }

  // ── Period Picker ──────────────────────────────────────────────────────────

  void _showPeriodPicker() {
    final options = [
      'Last 7 days',
      'Last 30 days',
      'Last 3 months',
      'This year',
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Period',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...options.map(
              (opt) => ListTile(
                title: Text(opt,
                    style: const TextStyle(fontSize: 14)),
                trailing: opt == _selectedPeriod
                    ? const Icon(Icons.check,
                        color: Color(0xFF0B8A8A), size: 18)
                    : null,
                onTap: () {
                  setState(() => _selectedPeriod = opt);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Expense Tile (unchanged) ─────────────────────────────────────────────────

class _ExpenseTile extends StatelessWidget {
  final ExpenseItem item;
  const _ExpenseTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFFEEEAE2), width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.date}     ${item.note}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8A8E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '- ₹ ${item.amount}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB85C1A),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Entry point (standalone testing) ────────────────────────────────────────

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RecentExpensesPage(),
    ),
  );
}