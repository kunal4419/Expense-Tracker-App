import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense.dart';

class ExpenseRepository {
  final SupabaseClient _client;

  ExpenseRepository(this._client);

  Future<List<Expense>> getExpenses({
    String? searchTitle,
    int? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    bool sortByNewest = true,
  }) async {
    dynamic query = _client.from('expenses').select('*, categories(*)');

    if (searchTitle != null && searchTitle.trim().isNotEmpty) {
      query = query.ilike('title', '%$searchTitle%');
    }

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    if (startDate != null) {
      query = query.gte('expense_date', startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      query = query.lte('expense_date', endDate.toIso8601String().split('T')[0]);
    }

    // Secondary sorting by created_at desc to handle elements on the same date consistently
    query = query.order('expense_date', ascending: !sortByNewest);
    query = query.order('created_at', ascending: !sortByNewest);

    final response = await query;
    return (response as List).map((json) => Expense.fromJson(json)).toList();
  }

  Future<Expense> createExpense(Expense expense) async {
    final currentUserId = _client.auth.currentUser?.id;
    final json = expense.toJson();
    if (currentUserId != null) {
      json['user_id'] = currentUserId;
    }
    json.remove('id');
    json.remove('created_at');
    json.remove('categories'); // Remove relation representation before sending to insert
    
    final response = await _client
        .from('expenses')
        .insert(json)
        .select('*, categories(*)')
        .single();
    return Expense.fromJson(response);
  }

  Future<Expense> updateExpense(Expense expense) async {
    final json = expense.toJson();
    json.remove('created_at');
    json.remove('categories'); // Remove relation representation before sending to update
    
    final response = await _client
        .from('expenses')
        .update(json)
        .eq('id', expense.id!)
        .select('*, categories(*)')
        .single();
    return Expense.fromJson(response);
  }

  Future<void> deleteExpense(int expenseId) async {
    await _client.from('expenses').delete().eq('id', expenseId);
  }

  Future<double> getTodayTotal() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _client
        .from('expenses')
        .select('amount')
        .eq('expense_date', today);
    return (response as List).fold<double>(0.0, (sum, item) => sum + (item['amount'] as num).toDouble());
  }

  Future<double> getMonthTotal() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
    final lastDay = DateTime(now.year, now.month + 1, 0).toIso8601String().split('T')[0];
    final response = await _client
        .from('expenses')
        .select('amount')
        .gte('expense_date', firstDay)
        .lte('expense_date', lastDay);
    return (response as List).fold<double>(0.0, (sum, item) => sum + (item['amount'] as num).toDouble());
  }

  Future<double> getTotalExpense() async {
    final response = await _client
        .from('expenses')
        .select('amount');
    return (response as List).fold<double>(0.0, (sum, item) => sum + (item['amount'] as num).toDouble());
  }

  Future<List<Expense>> getRecentExpenses({int limit = 5}) async {
    final response = await _client
        .from('expenses')
        .select('*, categories(*)')
        .order('expense_date', ascending: false)
        .order('created_at', ascending: false)
        .limit(limit);
    return (response as List).map((json) => Expense.fromJson(json)).toList();
  }
}
