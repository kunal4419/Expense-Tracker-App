import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../providers/expense_provider.dart';
import '../../providers/sales_provider.dart';
import '../../models/expense.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  bool _isExporting = false;
  double _yearlyTotal = 0.0;
  List<Expense> _allExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    final repo = ref.read(expenseRepositoryProvider);
    try {
      final list = await repo.getExpenses(sortByNewest: true);
      
      final now = DateTime.now();
      final yearStart = DateTime(now.year, 1, 1);
      final yearEnd = DateTime(now.year, 12, 31);
      
      double yearSum = 0.0;
      for (final e in list) {
        if (e.expenseDate.isAfter(yearStart.subtract(const Duration(days: 1))) &&
            e.expenseDate.isBefore(yearEnd.add(const Duration(days: 1)))) {
          yearSum += e.amount;
        }
      }

      setState(() {
        _allExpenses = list;
        _yearlyTotal = yearSum;
      });
    } catch (e) {
      debugPrint('Error loading report data: $e');
    }
  }

  DateTime? _selectedMonth;

  List<DateTime> _getRecentMonths() {
    final now = DateTime.now();
    return List.generate(12, (index) {
      return DateTime(now.year, now.month - index, 1);
    });
  }

  Future<void> _exportPdf() async {
    final expensesToExport = _selectedMonth == null
        ? _allExpenses
        : _allExpenses.where((e) =>
            e.expenseDate.year == _selectedMonth!.year &&
            e.expenseDate.month == _selectedMonth!.month).toList();

    if (expensesToExport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedMonth == null
              ? 'No expenses recorded to export.'
              : 'No expenses recorded for ${DateFormat('MMMM yyyy').format(_selectedMonth!)} to export.'),
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final pdf = pw.Document();
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 2);
      
      double targetExpenses = 0.0;
      double targetSales = 0.0;

      if (_selectedMonth != null) {
        targetExpenses = expensesToExport.fold(0.0, (sum, e) => sum + e.amount);

        final salesList = ref.read(salesProvider).sales;
        final filteredSales = salesList.where((s) =>
            s.entryDate.year == _selectedMonth!.year &&
            s.entryDate.month == _selectedMonth!.month).toList();
        targetSales = filteredSales.fold(0.0, (sum, s) => sum + s.morningSales + s.eveningSales);
      } else {
        targetExpenses = _allExpenses.fold(0.0, (sum, e) => sum + e.amount);

        final salesList = ref.read(salesProvider).sales;
        targetSales = salesList.fold(0.0, (sum, s) => sum + s.morningSales + s.eveningSales);
      }

      final netProfitLoss = targetSales - targetExpenses;
      final reportTitle = _selectedMonth == null
          ? 'Financial Summary Report (All Time)'
          : 'Financial Summary Report (${DateFormat('MMMM yyyy').format(_selectedMonth!)})';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(reportTitle, 
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Date: $dateStr', style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Total Logged Transactions: ${expensesToExport.length}', 
                style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 15),

            // Financial Summary Block
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Monthly Metrics Overview', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Sales:'),
                      pw.Text(currencyFormat.format(targetSales), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Expenses:'),
                      pw.Text(currencyFormat.format(targetExpenses), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Divider(),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Profit / Loss:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                        currencyFormat.format(netProfitLoss),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: netProfitLoss >= 0 ? PdfColors.green : PdfColors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Title', 'Category', 'Payment Mode', 'Amount'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                4: pw.Alignment.centerRight,
              },
              data: expensesToExport.map((e) {
                return [
                  DateFormat('yyyy-MM-dd').format(e.expenseDate),
                  e.title,
                  e.category?.name ?? 'Uncategorized',
                  e.paymentMode,
                  currencyFormat.format(e.amount),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total Spendings: ${currencyFormat.format(expensesToExport.fold<double>(0.0, (sum, e) => sum + e.amount))}',
                style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(), 
        name: 'expense_summary_report_$dateStr.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    final salesState = ref.watch(salesProvider);
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final netProfitLoss = salesState.monthTotal - expenseState.monthTotal;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(expenseProvider.notifier).refreshAll();
          await ref.read(salesProvider.notifier).fetchSales();
          await _loadReportData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reports & Export',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(4),
              Text(
                'Analyze cumulative metrics and export database files.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(24),

              // Aggregation Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 1,
                childAspectRatio: MediaQuery.of(context).size.width > 800 ? 1.8 : 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _ReportStatCard(
                    title: 'Daily Spendings',
                    amount: currencyFormat.format(expenseState.todayTotal),
                    icon: Icons.today,
                    color: theme.colorScheme.primary,
                  ),
                  _ReportStatCard(
                    title: 'Monthly Spendings',
                    amount: currencyFormat.format(expenseState.monthTotal),
                    icon: Icons.calendar_month,
                    color: theme.colorScheme.secondary,
                  ),
                  _ReportStatCard(
                    title: 'Yearly Spendings',
                    amount: currencyFormat.format(_yearlyTotal),
                    icon: Icons.auto_graph,
                    color: theme.colorScheme.tertiary,
                  ),
                  _ReportStatCard(
                    title: 'Monthly Sales',
                    amount: currencyFormat.format(salesState.monthTotal),
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                  _ReportStatCard(
                    title: 'Net Profit / Loss',
                    amount: currencyFormat.format(netProfitLoss),
                    icon: netProfitLoss >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: netProfitLoss >= 0 ? Colors.teal : Colors.red,
                  ),
                ],
              ),
              const Gap(24),

              // PDF Export Action Panel
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 500;
                      final textContent = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Export Financial Summary',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Generate a beautifully structured PDF document listing all transaction records, category classifications, and totals.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Gap(12),
                          Row(
                            children: [
                              Text(
                                'Select Month: ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(8),
                              DropdownButton<DateTime?>(
                                value: _selectedMonth,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('All Time'),
                                  ),
                                  ..._getRecentMonths().map((m) {
                                    return DropdownMenuItem(
                                      value: m,
                                      child: Text(DateFormat('MMMM yyyy').format(m)),
                                    );
                                  }),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _selectedMonth = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      );

                      final exportButton = ElevatedButton.icon(
                        onPressed: _isExporting ? null : _exportPdf,
                        icon: _isExporting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.download),
                        label: const Text('Export PDF'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );

                      if (isWide) {
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.picture_as_pdf,
                                color: theme.colorScheme.error,
                                size: 32,
                              ),
                            ),
                            const Gap(20),
                            Expanded(child: textContent),
                            const Gap(20),
                            exportButton,
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.errorContainer.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.picture_as_pdf,
                                    color: theme.colorScheme.error,
                                    size: 24,
                                  ),
                                ),
                                const Gap(16),
                                Expanded(child: textContent),
                              ],
                            ),
                            const Gap(16),
                            exportButton,
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportStatCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const _ReportStatCard({
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
