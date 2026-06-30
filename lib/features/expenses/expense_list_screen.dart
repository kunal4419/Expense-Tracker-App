import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import '../../providers/expense_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/expense.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate search if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.text = ref.read(expenseProvider).filter.searchQuery;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _parseColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final expenseNotifier = ref.read(expenseProvider.notifier);
    final currentFilter = ref.read(expenseProvider).filter;

    final initialRange = currentFilter.startDate != null && currentFilter.endDate != null
        ? DateTimeRange(start: currentFilter.startDate!, end: currentFilter.endDate!)
        : null;

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      expenseNotifier.updateFilter((f) => f.copyWith(
            startDate: picked.start,
            endDate: picked.end,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    final categoryState = ref.watch(categoryProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    final activeFilter = expenseState.filter;
    final isFiltered = activeFilter.searchQuery.isNotEmpty ||
        activeFilter.categoryId != null ||
        activeFilter.startDate != null ||
        activeFilter.endDate != null;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(expenseProvider.notifier).fetchExpenses(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expenses List',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),

              // Filter Controls Bar
              // Modern Compact Search & Filter Panel
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search expenses...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(expenseProvider.notifier).updateFilter(
                                      (f) => f.copyWith(searchQuery: ''),
                                    );
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.15),
                    ),
                    onChanged: (val) {
                      ref.read(expenseProvider.notifier).updateFilter(
                            (f) => f.copyWith(searchQuery: val),
                          );
                      setState(() {});
                    },
                  ),
                  const Gap(10),

                  // Horizontal Scrolling Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        // Sort Order Chip
                        ActionChip(
                          avatar: Icon(
                            activeFilter.sortByNewest 
                                ? Icons.arrow_downward 
                                : Icons.arrow_upward,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          label: Text(activeFilter.sortByNewest ? 'Newest' : 'Oldest'),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          onPressed: () {
                            ref.read(expenseProvider.notifier).updateFilter(
                                  (f) => f.copyWith(sortByNewest: !f.sortByNewest),
                                );
                          },
                        ),
                        const Gap(8),

                        // Timeframe Options (All, Today, Week, Month)
                        _buildTimeframeChip('All', activeFilter.startDate == null),
                        const Gap(8),
                        _buildTimeframeChip('Today', _isSameDay(activeFilter.startDate, DateTime.now())),
                        const Gap(8),
                        _buildTimeframeChip('This Week', _isThisWeek(activeFilter.startDate)),
                        const Gap(8),
                        _buildTimeframeChip('This Month', _isThisMonthStart(activeFilter.startDate)),
                        const Gap(8),

                        // Custom Date Range Chip
                        InputChip(
                          selected: activeFilter.startDate != null && 
                                    !_isSameDay(activeFilter.startDate, DateTime.now()) &&
                                    !_isThisWeek(activeFilter.startDate) &&
                                    !_isThisMonthStart(activeFilter.startDate),
                          onSelected: (_) => _selectDateRange(context),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          label: Text(
                            activeFilter.startDate != null && activeFilter.endDate != null &&
                            !_isSameDay(activeFilter.startDate, DateTime.now()) &&
                            !_isThisWeek(activeFilter.startDate) &&
                            !_isThisMonthStart(activeFilter.startDate)
                                ? '${DateFormat('MMM dd').format(activeFilter.startDate!)} - ${DateFormat('MMM dd').format(activeFilter.endDate!)}'
                                : 'Custom Dates',
                          ),
                          onDeleted: activeFilter.startDate != null && 
                                    !_isSameDay(activeFilter.startDate, DateTime.now()) &&
                                    !_isThisWeek(activeFilter.startDate) &&
                                    !_isThisMonthStart(activeFilter.startDate)
                              ? () {
                                  ref.read(expenseProvider.notifier).updateFilter((f) => f.copyWith(
                                    clearDates: true,
                                  ));
                                }
                              : null,
                        ),
                        const Gap(8),

                        // Category Selector Chip (styled as PopupMenuButton with Container child to prevent tap interception)
                        PopupMenuButton<int?>(
                          onSelected: (val) {
                            ref.read(expenseProvider.notifier).updateFilter((f) {
                              if (val == null) {
                                  return f.copyWith(clearCategory: true);
                              }
                              return f.copyWith(categoryId: val);
                            });
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: null,
                              child: Text('All Categories'),
                            ),
                            ...categoryState.categories.map((c) => PopupMenuItem(
                                  value: c.id,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: _parseColor(c.color),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const Gap(8),
                                      Text(c.name),
                                    ],
                                  ),
                                )),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: activeFilter.categoryId != null 
                                  ? theme.colorScheme.primaryContainer.withOpacity(0.4) 
                                  : theme.colorScheme.surfaceContainerHigh.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: activeFilter.categoryId != null 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.outlineVariant,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  activeFilter.categoryId != null && categoryState.categories.isNotEmpty
                                      ? 'Category: ${categoryState.categories.firstWhere((c) => c.id == activeFilter.categoryId, orElse: () => categoryState.categories.first).name}'
                                      : 'Category',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: activeFilter.categoryId != null 
                                        ? theme.colorScheme.primary 
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontWeight: activeFilter.categoryId != null ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                if (activeFilter.categoryId != null) ...[
                                  const Gap(4),
                                  GestureDetector(
                                    onTap: () {
                                      ref.read(expenseProvider.notifier).updateFilter((f) => f.copyWith(
                                        clearCategory: true,
                                      ));
                                    },
                                    child: Icon(
                                      Icons.cancel,
                                      size: 14,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ] else ...[
                                  const Gap(4),
                                  Icon(
                                    Icons.arrow_drop_down, 
                                    size: 16,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        if (isFiltered) ...[
                          const Gap(8),
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              ref.read(expenseProvider.notifier).clearFilters();
                            },
                            icon: const Icon(Icons.filter_alt_off, size: 16),
                            label: const Text('Clear'),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const Gap(20),

              if (expenseState.isLoading && expenseState.expenses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (expenseState.expenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                        ),
                        const Gap(16),
                        Text(
                          'No matching expenses found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          isFiltered 
                              ? 'Try refining your search terms or filters.'
                              : 'Tap the Floating Action Button (+) below to record your first expense.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenseState.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenseState.expenses[index];
                    final categoryName = expense.category?.name ?? 'Uncategorized';
                    final categoryColor = expense.category?.color != null 
                        ? _parseColor(expense.category!.color) 
                        : Colors.indigo;

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      color: theme.colorScheme.surfaceContainerHigh.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () => context.go('/expenses/detail', extra: expense),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.receipt_long,
                            color: categoryColor,
                          ),
                        ),
                        title: Text(
                          expense.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                categoryName,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: categoryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Gap(8),
                            Text(
                              DateFormat('MMM dd, yyyy').format(expense.expenseDate),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currencyFormat.format(expense.amount),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  expense.paymentMode,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            const Icon(Icons.chevron_right, size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/expenses/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  bool _isSameDay(DateTime? d1, DateTime? d2) {
    if (d1 == null || d2 == null) return false;
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool _isThisWeek(DateTime? d) {
    if (d == null) return false;
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(start.year, start.month, start.day);
    return _isSameDay(d, startOfDay);
  }

  bool _isThisMonthStart(DateTime? d) {
    if (d == null) return false;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return _isSameDay(d, start);
  }

  void _setTimeframe(String type) {
    final now = DateTime.now();
    final expenseNotifier = ref.read(expenseProvider.notifier);
    
    if (type == 'All') {
      expenseNotifier.updateFilter((f) => f.copyWith(
        clearDates: true,
      ));
    } else if (type == 'Today') {
      final start = DateTime(now.year, now.month, now.day);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      expenseNotifier.updateFilter((f) => f.copyWith(
        startDate: start,
        endDate: end,
      ));
    } else if (type == 'This Week') {
      final start = now.subtract(Duration(days: now.weekday - 1));
      final startOfDay = DateTime(start.year, start.month, start.day);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      expenseNotifier.updateFilter((f) => f.copyWith(
        startDate: startOfDay,
        endDate: end,
      ));
    } else if (type == 'This Month') {
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      expenseNotifier.updateFilter((f) => f.copyWith(
        startDate: start,
        endDate: end,
      ));
    }
  }

  Widget _buildTimeframeChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (selected) {
        if (selected) {
          _setTimeframe(label);
        }
      },
    );
  }
}
