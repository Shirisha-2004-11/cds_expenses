// ─────────────────────────────────────────────────────────────────────────────
// lib/Dashboard_path/Expenses_History.dart  (UPDATED — grouped by category)
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

  static const _filters = [
    'All', 'Food', 'Travel', 'Supplies', 'Bills', 'Entertainment',
    'Medical', 'Education', 'Rent', 'Petrol', 'Electricity', 'Home Services',
  ];

  /// Returns expenses filtered by selected category
  List<Expense> get _filtered {
    final all = widget.provider.allExpenses;
    if (_selectedFilter == 'All') return all;
    return all
        .where((e) => e.category.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  /// Groups expenses into an ordered map: category → list of Expense
  Map<String, List<Expense>> get _grouped {
    final expenses = _filtered;
    final map = <String, List<Expense>>{};

    if (_selectedFilter != 'All') {
      // Single category selected — one group only
      map[_selectedFilter] = expenses;
      return map;
    }

    // "All" selected: group by category preserving order of first appearance
    for (final e in expenses) {
      map.putIfAbsent(e.category, () => []).add(e);
    }

    // Sort groups by total descending so biggest spends appear first
    final sorted = Map.fromEntries(
      map.entries.toList()
        ..sort((a, b) {
          final aTotal = a.value.fold(0.0, (s, x) => s + x.amount);
          final bTotal = b.value.fold(0.0, (s, x) => s + x.amount);
          return bTotal.compareTo(aTotal);
        }),
    );
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final expenses = _filtered;
    final total = expenses.fold(0.0, (s, e) => s + e.amount);
    final grouped = _grouped;

    // Flatten grouped map into a mixed list: headers + expense items
    final List<_ListItem> listItems = [];
    for (final entry in grouped.entries) {
      final catExpenses = entry.value;
      if (catExpenses.isEmpty) continue;
      final catTotal = catExpenses.fold(0.0, (s, e) => s + e.amount);
      listItems.add(_HeaderItem(category: entry.key, total: catTotal));
      for (final e in catExpenses) {
        listItems.add(_ExpenseItem(expense: e));
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Expenses',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '₹ ${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2A7A50),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter chips ─────────────────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final isActive = f == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF1A1A2E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? const Color(0xFF1A1A2E) : const Color(0xFFDDDDDD),
                      ),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.white : const Color(0xFF666666),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Grouped expense list ─────────────────────────────────────────
          Expanded(
            child: listItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          _selectedFilter == 'All'
                              ? 'No expenses yet'
                              : 'No $_selectedFilter expenses',
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: listItems.length,
                    itemBuilder: (_, i) {
                      final item = listItems[i];
                      if (item is _HeaderItem) {
                        return _CategoryHeader(
                          category: item.category,
                          total: item.total,
                        );
                      } else if (item is _ExpenseItem) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: _ExpenseTile(expense: item.expense),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── List item models ──────────────────────────────────────────────────────────

abstract class _ListItem {}

class _HeaderItem extends _ListItem {
  final String category;
  final double total;
  _HeaderItem({required this.category, required this.total});
}

class _ExpenseItem extends _ListItem {
  final Expense expense;
  _ExpenseItem({required this.expense});
}

// ─── Category section header ───────────────────────────────────────────────────

class _CategoryHeader extends StatelessWidget {
  final String category;
  final double total;

  const _CategoryHeader({required this.category, required this.total});

  @override
  Widget build(BuildContext context) {
    final dummy = Expense(
      id: '', category: category, merchant: '',
      date: '', note: '', amount: 0, paymentMethod: '',
    );
    final color = dummy.color;
    final icon  = dummy.icon;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          // Coloured icon badge
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 10),
          // Category name
          Text(
            category,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(width: 8),
          // Hairline divider
          Expanded(child: Container(height: 1, color: const Color(0xFFEEEEEE))),
          const SizedBox(width: 8),
          // Category subtotal
          Text(
            '₹ ${total.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Expense Tile ──────────────────────────────────────────────────────────────

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
      } else if (d.year == today.year &&
                 d.month == today.month &&
                 d.day == today.day - 1) {
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: e.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(e.icon, color: e.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.merchant.isNotEmpty ? e.merchant : e.category,
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(dateLabel,
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    if (e.note.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '· ${e.note}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
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
              Text(
                '-₹ ${e.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFE53935),
                ),
              ),
              Text(
                e.paymentMethod.replaceAll('_', ' '),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
