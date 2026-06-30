import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import '../../providers/sales_provider.dart';
import '../../models/sales.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  Future<void> _showSalesDialog([Sales? existingSales]) async {
    final isEdit = existingSales != null;
    final formKey = GlobalKey<FormState>();
    final morningController = TextEditingController(
      text: isEdit ? existingSales.morningSales.toString() : '',
    );
    final eveningController = TextEditingController(
      text: isEdit ? existingSales.eveningSales.toString() : '',
    );
    DateTime selectedDate = isEdit ? existingSales.entryDate : DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Update Sales Entry' : 'New Sales Entry'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Date Selector Row
                      InkWell(
                        onTap: isEdit
                            ? null // Don't change date on edit
                            : () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setDialogState(() {
                                    selectedDate = picked;
                                  });
                                }
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18),
                              const Gap(12),
                              Expanded(
                                child: Text(
                                  DateFormat('yyyy-MM-dd').format(selectedDate),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (!isEdit) const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const Gap(16),

                      // Morning Sales Input
                      TextFormField(
                        controller: morningController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Morning Sales (₹)',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.light_mode),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter morning sales';
                          if (double.tryParse(val.trim()) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const Gap(16),

                      // Evening Sales Input
                      TextFormField(
                        controller: eveningController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Evening Sales (₹)',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.dark_mode_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter evening sales';
                          if (double.tryParse(val.trim()) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    final morning = double.parse(morningController.text.trim());
                    final evening = double.parse(eveningController.text.trim());

                    try {
                      await ref.read(salesProvider.notifier).addOrUpdateSales(
                            date: selectedDate,
                            morningSales: morning,
                            eveningSales: evening,
                          );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEdit
                                ? 'Sales updated successfully!'
                                : 'Sales recorded successfully!'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to save sales: $e'),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isEdit ? 'Update' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final salesState = ref.watch(salesProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(salesProvider.notifier).fetchSales(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Sales',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(4),
              Text(
                'Manage daily shop collections and morning/evening inputs.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(24),

              // Aggregation Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: size.width > 800 ? 3 : 1,
                childAspectRatio: size.width > 800 ? 1.8 : 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _SalesStatCard(
                    title: "Today's Sales",
                    amount: _currencyFormat.format(salesState.todayTotal),
                    icon: Icons.today,
                    color: theme.colorScheme.primary,
                  ),
                  _SalesStatCard(
                    title: "This Month's Sales",
                    amount: _currencyFormat.format(salesState.monthTotal),
                    icon: Icons.calendar_month,
                    color: theme.colorScheme.secondary,
                  ),
                  _SalesStatCard(
                    title: 'Total Cumulative Sales',
                    amount: _currencyFormat.format(salesState.totalSales),
                    icon: Icons.trending_up,
                    color: theme.colorScheme.tertiary,
                  ),
                ],
              ),
              const Gap(32),

              Text(
                'Sales Logs',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),

              if (salesState.isLoading && salesState.sales.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (salesState.sales.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.insights,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const Gap(16),
                        Text(
                          'No sales recorded yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          'Tap the button below to add your first sales entry.',
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
                  itemCount: salesState.sales.length,
                  itemBuilder: (context, index) {
                    final item = salesState.sales[index];
                    final dailyTotal = item.morningSales + item.eveningSales;

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      color: theme.colorScheme.surfaceContainerHigh.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.monetization_on_outlined,
                                    color: theme.colorScheme.primary,
                                    size: 18,
                                  ),
                                ),
                                const Gap(10),
                                Expanded(
                                  child: Text(
                                    DateFormat('EEEE, MMM dd, yyyy').format(item.entryDate),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _showSalesDialog(item),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 18),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Entry'),
                                        content: const Text('Are you sure you want to delete this sales entry?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && item.id != null) {
                                      await ref.read(salesProvider.notifier).deleteSales(item.id!);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const Gap(8),
                            // Using a Row with wrap/alignment or Wrap for safety against small screens
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 4,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.light_mode, size: 14, color: theme.colorScheme.onSurfaceVariant),
                                          const Gap(4),
                                          Text(
                                            'Morning: ${_currencyFormat.format(item.morningSales)}',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.dark_mode_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                                          const Gap(4),
                                          Text(
                                            'Evening: ${_currencyFormat.format(item.eveningSales)}',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _currencyFormat.format(dailyTotal),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
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
        onPressed: () => _showSalesDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Sales'),
      ),
    );
  }
}

class _SalesStatCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const _SalesStatCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const Gap(8),
            Text(
              amount,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
