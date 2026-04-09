// ─────────────────────────────────────────────────────────────────────────────
// lib/Dashboard_path/Expenses_History.dart  (UPDATED — fully dynamic)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../services/expense_provider.dart';

class RecentExpensesPage extends StatefulWidget {
  final ExpenseProvider provider;

  const RecentExpensesPage({super.key, required this.provider});

  @override
  State<RecentExpensesPage> createState() => _RecentExpensesPageState();
}

class _RecentExpensesPageState extends State<RecentExpensesPage> {
  String _selectedFilter = 'All';

  static const _baseCategories = [
    'Food', 'Travel', 'Supplies', 'Bills', 'Entertainment',
    'Medical', 'Education', 'Rent', 'Petrol', 'Electricity', 'Home Services',
  ];

  /// Base categories + any custom categories found in actual expenses
  List<String> get _filters {
    final baseLower = _baseCategories.map((c) => c.toLowerCase()).toSet();
    final custom = widget.provider.allExpenses
        .map((e) => e.category)
        .where((c) => c.isNotEmpty && !baseLower.contains(c.toLowerCase()))
        .toSet()
        .toList()
      ..sort();
    return ['All', ..._baseCategories, ...custom];
  }

  List<Expense> get _filtered {
    final all = widget.provider.allExpenses;
    if (_selectedFilter == 'All') return all;
    return all.where((e) => e.category.toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final expenses = _filtered;
    final total    = expenses.fold(0.0, (s, e) => s + e.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('All Expenses',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text('₹ ${total.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2A7A50))),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter chips ──
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f        = _filters[i];
                final isActive = f == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF1A1A2E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isActive ? const Color(0xFF1A1A2E) : const Color(0xFFDDDDDD)),
                    ),
                    child: Text(f,
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500,
                          color: isActive ? Colors.white : const Color(0xFF666666),
                        )),
                  ),
                );
              },
            ),
          ),

          // ── List ──
          Expanded(
            child: expenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          _selectedFilter == 'All' ? 'No expenses yet' : 'No $_selectedFilter expenses',
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: expenses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _ExpenseTile(expense: expenses[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Expense Tile ─────────────────────────────────────────────────────────────

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final e     = expense;
    final today = DateTime.now();
    final d     = e.parsedDate;
    String dateLabel = e.date;
    if (d != null) {
      if (d.year == today.year && d.month == today.month && d.day == today.day) {
        dateLabel = 'Today';
      } else if (d.year == today.year && d.month == today.month && d.day == today.day - 1) {
        dateLabel = 'Yesterday';
      } else {
        dateLabel = '${d.day}/${d.month}/${d.year}';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: e.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(e.icon, color: e.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.merchant.isNotEmpty ? e.merchant : e.category,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _Chip(label: e.category, color: e.color),
                    const SizedBox(width: 6),
                    Text(dateLabel, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    if (e.note.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('· ${e.note}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('-₹ ${e.amount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFE53935))),
              Text(e.paymentMethod.replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Chip ─────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color  color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
