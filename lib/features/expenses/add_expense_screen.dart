import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import '../../providers/expense_provider.dart';
import '../../providers/category_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMode = 'Cash';

  final List<String> _paymentModes = ['Cash', 'Card', 'UPI', 'Net Banking', 'Other'];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    try {
      await ref.read(expenseProvider.notifier).addExpense(
        title: _titleController.text.trim(),
        amount: amount,
        paymentMode: _selectedPaymentMode,
        expenseDate: _selectedDate,
        categoryId: _selectedCategoryId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding expense: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Track a New Expense',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Enter transaction details below to log this expense.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(24),

                  // Title Input
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g. Starbucks Coffee',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const Gap(16),

                  // Amount Input
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount (₹)',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(val) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const Gap(16),

                  // Category Select Dropdown
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.folder_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: categoryState.categories.map((c) {
                      return DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                      });
                    },
                    validator: (val) => val == null ? 'Please select a category' : null,
                  ),
                  const Gap(16),

                  // Date Selector Card
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHigh.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                              const Gap(12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Expense Date',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => _selectDate(context),
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(24),

                  // Payment Mode Header
                  Text(
                    'Payment Mode',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),

                  // Payment Mode Choice Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _paymentModes.map((mode) {
                      final isSelected = _selectedPaymentMode == mode;
                      return ChoiceChip(
                        label: Text(mode),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedPaymentMode = mode;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const Gap(32),

                  // Action Buttons
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Expense',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
