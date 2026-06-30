import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/category.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  static const List<Map<String, String>> _predefinedColors = [
    {'name': 'Indigo', 'value': '#5C6BC0'},
    {'name': 'Teal', 'value': '#26A69A'},
    {'name': 'Orange', 'value': '#FFA726'},
    {'name': 'Pink', 'value': '#EC407A'},
    {'name': 'Blue', 'value': '#42A5F5'},
    {'name': 'Purple', 'value': '#AB47BC'},
    {'name': 'Deep Orange', 'value': '#FF7043'},
    {'name': 'Amber', 'value': '#FFCA28'},
    {'name': 'Green', 'value': '#66BB6A'},
    {'name': 'Slate', 'value': '#78909C'},
  ];

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

  void _showCategoryDialog(BuildContext context, WidgetRef ref, {Category? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    String selectedColorHex = category?.color ?? _predefinedColors.first['value']!;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            return AlertDialog(
              title: Text(isEditing ? 'Edit Category' : 'Create Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                        hintText: 'e.g. Groceries',
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const Gap(20),
                    Text(
                      'Select Theme Color',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(10),
                    SizedBox(
                      width: 320,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _predefinedColors.map((colorMap) {
                          final hex = colorMap['value']!;
                          final isSelected = selectedColorHex == hex;
                          final color = _parseColor(hex);

                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                selectedColorHex = hex;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected 
                                      ? theme.colorScheme.onSurface 
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.4),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a category name')),
                      );
                      return;
                    }
                    try {
                      if (isEditing) {
                        final updated = category.copyWith(
                          name: name,
                          color: selectedColorHex,
                        );
                        await ref.read(categoryProvider.notifier).editCategory(updated);
                      } else {
                        await ref.read(categoryProvider.notifier).addCategory(
                          name,
                          selectedColorHex,
                        );
                      }
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: Text(isEditing ? 'Save' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref, Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete the category "${category.name}"? All associated expenses will remain but become uncategorized.'),
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
        await ref.read(categoryProvider.notifier).removeCategory(category.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category deleted successfully.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete category: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(categoryProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final currentUserId = authState.user?.id;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(categoryProvider.notifier).fetchCategories(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categories',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(4),
              Text(
                'Customize and organize categories for expense grouping.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(24),

              if (categoryState.isLoading && categoryState.categories.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 350,
                    mainAxisExtent: 88,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: categoryState.categories.length,
                  itemBuilder: (context, index) {
                    final category = categoryState.categories[index];
                    final catColor = _parseColor(category.color);
                    final isUserOwned = category.userId != null && category.userId == currentUserId;

                    return Card(
                      elevation: 0,
                      color: catColor.withOpacity(0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: catColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: catColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Gap(16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    category.isDefault ? 'System default' : 'Custom',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isUserOwned) ...[
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                tooltip: 'Edit',
                                onPressed: () => _showCategoryDialog(context, ref, category: category),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                tooltip: 'Delete',
                                onPressed: () => _deleteCategory(context, ref, category),
                              ),
                            ] else ...[
                              const Tooltip(
                                message: 'Read-only default category',
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.lock_outline, size: 18),
                                ),
                              ),
                            ]
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
        onPressed: () => _showCategoryDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Category'),
      ),
    );
  }
}
