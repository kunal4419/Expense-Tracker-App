import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

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

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete this expense record for "${expense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(expenseProvider.notifier).deleteExpense(expense.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense deleted successfully.')),
          );
          context.pop(); // Go back to expense list
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete expense: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final categoryName = expense.category?.name ?? 'Uncategorized';
    final categoryColor = expense.category?.color != null 
        ? _parseColor(expense.category!.color) 
        : Colors.indigo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Highlight Card
                Card(
                  elevation: 0,
                  color: categoryColor.withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: categoryColor.withOpacity(0.25), width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: categoryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const Gap(20),
                        Text(
                          expense.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          currencyFormat.format(expense.amount),
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(24),

                // Detail Attributes Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHigh.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.folder_outlined,
                          label: 'Category',
                          valueWidget: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: 13,
                                color: categoryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date',
                          value: DateFormat('EEEE, MMMM dd, yyyy').format(expense.expenseDate),
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.payment_outlined,
                          label: 'Payment Mode',
                          value: expense.paymentMode,
                        ),
                      ],
                    ),
                  ),
                ),

                const Gap(32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _delete(context, ref),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(color: theme.colorScheme.error),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/expenses/edit', extra: expense),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 22),
        const Gap(12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        valueWidget ??
            Text(
              value ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
      ],
    );
  }
}
