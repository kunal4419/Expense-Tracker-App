import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseState = ref.watch(expenseProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    final isLargeScreen = size.width > 800;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(expenseProvider.notifier).refreshAll(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Text(
                'Financial Overview',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(4),
              Text(
                'Keep track of your spending patterns and manage budgets.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(24),

              // Responsive Summary cards grid
              isLargeScreen
                  ? Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: "Today's Expense",
                            amount: currencyFormat.format(expenseState.todayTotal),
                            icon: Icons.today,
                            color: theme.colorScheme.primary,
                            backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: _SummaryCard(
                            title: 'This Month',
                            amount: currencyFormat.format(expenseState.monthTotal),
                            icon: Icons.calendar_month,
                            color: theme.colorScheme.secondary,
                            backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total Expense',
                            amount: currencyFormat.format(expenseState.totalExpense),
                            icon: Icons.account_balance_wallet,
                            color: theme.colorScheme.tertiary,
                            backgroundColor: theme.colorScheme.tertiaryContainer.withOpacity(0.5),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _SummaryCard(
                          title: "Today's Expense",
                          amount: currencyFormat.format(expenseState.todayTotal),
                          icon: Icons.today,
                          color: theme.colorScheme.primary,
                          backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
                        ),
                        const Gap(12),
                        _SummaryCard(
                          title: 'This Month',
                          amount: currencyFormat.format(expenseState.monthTotal),
                          icon: Icons.calendar_month,
                          color: theme.colorScheme.secondary,
                          backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                        ),
                        const Gap(12),
                        _SummaryCard(
                          title: 'Total Expense',
                          amount: currencyFormat.format(expenseState.totalExpense),
                          icon: Icons.account_balance_wallet,
                          color: theme.colorScheme.tertiary,
                          backgroundColor: theme.colorScheme.tertiaryContainer.withOpacity(0.5),
                        ),
                      ],
                    ),
              
              const Gap(32),

              // Recent Expenses Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Expenses',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/expenses'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const Gap(12),

              if (expenseState.isLoading && expenseState.recentExpenses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (expenseState.recentExpenses.isEmpty)
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                          ),
                          const Gap(16),
                          Text(
                            'No Expenses Recorded Yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            'Tap the Floating Action Button (+) to add your first expense.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenseState.recentExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenseState.recentExpenses[index];
                    return _RecentExpenseTile(
                      expense: expense,
                      currencyFormat: currencyFormat,
                      onTap: () => context.go('/expenses/detail', extra: expense),
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
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    amount,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentExpenseTile extends StatelessWidget {
  final Expense expense;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  const _RecentExpenseTile({
    required this.expense,
    required this.currencyFormat,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryName = expense.category?.name ?? 'Uncategorized';
    final categoryColor = expense.category?.color != null 
        ? _parseColor(expense.category!.color) 
        : Colors.indigo;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surfaceContainerHigh.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
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
  }
}
