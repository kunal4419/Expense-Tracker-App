import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sales.dart';
import '../repositories/sales_repository.dart';
import 'auth_provider.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(ref.watch(supabaseClientProvider));
});

class SalesState {
  final List<Sales> sales;
  final bool isLoading;
  final double todayTotal;
  final double monthTotal;
  final double totalSales;
  final String? error;

  SalesState({
    this.sales = const [],
    this.isLoading = false,
    this.todayTotal = 0.0,
    this.monthTotal = 0.0,
    this.totalSales = 0.0,
    this.error,
  });

  SalesState copyWith({
    List<Sales>? sales,
    bool? isLoading,
    double? todayTotal,
    double? monthTotal,
    double? totalSales,
    String? error,
  }) {
    return SalesState(
      sales: sales ?? this.sales,
      isLoading: isLoading ?? this.isLoading,
      todayTotal: todayTotal ?? this.todayTotal,
      monthTotal: monthTotal ?? this.monthTotal,
      totalSales: totalSales ?? this.totalSales,
      error: error,
    );
  }
}

class SalesNotifier extends StateNotifier<SalesState> {
  final SalesRepository _salesRepository;

  SalesNotifier(this._salesRepository) : super(SalesState()) {
    fetchSales();
  }

  Future<void> fetchSales() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      final list = await _salesRepository.getSales();
      if (!mounted) return;

      final now = DateTime.now();
      double todaySum = 0.0;
      double monthSum = 0.0;
      double totalSum = 0.0;

      for (final s in list) {
        final dailyTotal = s.morningSales + s.eveningSales;
        totalSum += dailyTotal;

        // Check if today
        if (s.entryDate.year == now.year &&
            s.entryDate.month == now.month &&
            s.entryDate.day == now.day) {
          todaySum += dailyTotal;
        }

        // Check if this month
        if (s.entryDate.year == now.year && s.entryDate.month == now.month) {
          monthSum += dailyTotal;
        }
      }

      state = state.copyWith(
        sales: list,
        todayTotal: todaySum,
        monthTotal: monthSum,
        totalSales: totalSum,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addOrUpdateSales({
    required DateTime date,
    required double morningSales,
    required double eveningSales,
  }) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      // Check if sales for this date already exists to preserve the ID for upsert
      final dateStr = date.toIso8601String().split('T')[0];
      final existing = state.sales.firstWhere(
        (s) => s.entryDate.toIso8601String().split('T')[0] == dateStr,
        orElse: () => Sales(
          userId: '',
          morningSales: 0,
          eveningSales: 0,
          entryDate: DateTime(2000),
        ),
      );

      final sales = Sales(
        id: existing.id != 2000 && existing.id != null ? existing.id : null,
        userId: '',
        morningSales: morningSales,
        eveningSales: eveningSales,
        entryDate: date,
      );

      await _salesRepository.upsertSales(sales);
      await fetchSales();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteSales(int id) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      await _salesRepository.deleteSales(id);
      await fetchSales();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void reset() {
    state = SalesState();
  }
}

final salesProvider = StateNotifierProvider<SalesNotifier, SalesState>((ref) {
  final authState = ref.watch(authProvider);
  final repo = ref.watch(salesRepositoryProvider);
  final notifier = SalesNotifier(repo);

  if (authState.user == null) {
    notifier.reset();
  } else {
    notifier.fetchSales();
  }
  return notifier;
});
