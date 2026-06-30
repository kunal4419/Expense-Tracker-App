import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sales.dart';

class SalesRepository {
  final SupabaseClient _client;

  SalesRepository(this._client);

  Future<List<Sales>> getSales() async {
    final response = await _client
        .from('sales')
        .select()
        .order('entry_date', ascending: false);
    return (response as List).map((json) => Sales.fromJson(json)).toList();
  }

  Future<Sales?> getSalesForDate(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await _client
        .from('sales')
        .select()
        .eq('entry_date', dateStr)
        .maybeSingle();
    if (response == null) return null;
    return Sales.fromJson(response);
  }

  Future<Sales> upsertSales(Sales sales) async {
    final currentUserId = _client.auth.currentUser?.id;
    final json = sales.toJson();
    if (currentUserId != null) {
      json['user_id'] = currentUserId;
    }
    
    // If id is null, remove it so DB auto-generates or handles upsert correctly
    if (sales.id == null) {
      json.remove('id');
    }
    json.remove('created_at');
    
    json['entry_date'] = sales.entryDate.toIso8601String().split('T')[0];

    final response = await _client
        .from('sales')
        .upsert(json, onConflict: 'user_id, entry_date')
        .select()
        .single();
    return Sales.fromJson(response);
  }

  Future<void> deleteSales(int id) async {
    await _client.from('sales').delete().eq('id', id);
  }
}
