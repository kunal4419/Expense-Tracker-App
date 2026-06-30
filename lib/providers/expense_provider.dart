import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import 'auth_provider.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(supabaseClientProvider));
});

class ExpenseFilter {
  final String searchQuery;
  final int? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool sortByNewest;

  ExpenseFilter({
    this.searchQuery = '',
    this.categoryId,
    this.startDate,
    this.endDate,
    this.sortByNewest = true,
  });

  ExpenseFilter copyWith({
    String? searchQuery,
    int? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    bool? sortByNewest,
    bool clearCategory = false,
    bool clearDates = false,
  }) {
    return ExpenseFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      sortByNewest: sortByNewest ?? this.sortByNewest,
    );
  }
}

class ExpenseState {
  final List<Expense> expenses;
  final List<Expense> recentExpenses;
  final ExpenseFilter filter;
  final bool isLoading;
  final double todayTotal;
  final double monthTotal;
  final double totalExpense;
  final String? error;

  ExpenseState({
    this.expenses = const [],
    this.recentExpenses = const [],
    required this.filter,
    this.isLoading = false,
    this.todayTotal = 0.0,
    this.monthTotal = 0.0,
    this.totalExpense = 0.0,
    this.error,
  });

  ExpenseState copyWith({
    List<Expense>? expenses,
    List<Expense>? recentExpenses,
    ExpenseFilter? filter,
    bool? isLoading,
    double? todayTotal,
    double? monthTotal,
    double? totalExpense,
    String? error,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      recentExpenses: recentExpenses ?? this.recentExpenses,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      todayTotal: todayTotal ?? this.todayTotal,
      monthTotal: monthTotal ?? this.monthTotal,
      totalExpense: totalExpense ?? this.totalExpense,
      error: error,
    );
  }
}

class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final ExpenseRepository _expenseRepository;

  ExpenseNotifier(this._expenseRepository)
      : super(ExpenseState(filter: ExpenseFilter())) {
    refreshAll();
  }

  Future<void> refreshAll() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    await Future.wait([
      fetchExpenses(),
      fetchDashboardData(),
    ]);
    if (!mounted) return;
    state = state.copyWith(isLoading: false);
  }

  Future<void> fetchExpenses() async {
    try {
      final list = await _expenseRepository.getExpenses(
        searchTitle: state.filter.searchQuery,
        categoryId: state.filter.categoryId,
        startDate: state.filter.startDate,
        endDate: state.filter.endDate,
        sortByNewest: state.filter.sortByNewest,
      );
      if (!mounted) return;
      state = state.copyWith(expenses: list);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      final today = await _expenseRepository.getTodayTotal();
      final month = await _expenseRepository.getMonthTotal();
      final total = await _expenseRepository.getTotalExpense();
      final recent = await _expenseRepository.getRecentExpenses(limit: 5);
      if (!mounted) return;
      state = state.copyWith(
        todayTotal: today,
        monthTotal: month,
        totalExpense: total,
        recentExpenses: recent,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e.toString());
    }
  }

  void updateFilter(ExpenseFilter Function(ExpenseFilter current) filterUpdater) {
    state = state.copyWith(filter: filterUpdater(state.filter));
    fetchExpenses();
  }

  void clearFilters() {
    state = state.copyWith(
      filter: ExpenseFilter(),
    );
    fetchExpenses();
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String paymentMode,
    required DateTime expenseDate,
    int? categoryId,
  }) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      // Temporary userId placeholder, repository handles setting active user ID from Supabase
      final newExp = Expense(
        userId: '',
        title: title,
        amount: amount,
        paymentMode: paymentMode,
        expenseDate: expenseDate,
        categoryId: categoryId,
      );
      await _expenseRepository.createExpense(newExp);
      await refreshAll();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> editExpense(Expense expense) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      await _expenseRepository.updateExpense(expense);
      await refreshAll();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteExpense(int expenseId) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      await _expenseRepository.deleteExpense(expenseId);
      await refreshAll();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void reset() {
    state = ExpenseState(filter: ExpenseFilter());
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
  // Clear or reload when user status changes
  final authState = ref.watch(authProvider);
  final repo = ref.watch(expenseRepositoryProvider);
  final notifier = ExpenseNotifier(repo);
  
  // If user signs out, we can reset, otherwise refresh
  if (authState.user == null) {
    notifier.reset();
  } else {
    notifier.refreshAll();
  }
  return notifier;
});
