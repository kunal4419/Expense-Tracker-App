import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

class CategoryRepository {
  final SupabaseClient _client;

  CategoryRepository(this._client);

  Future<List<Category>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .order('name', ascending: true);
    return (response as List).map((json) => Category.fromJson(json)).toList();
  }

  Future<Category> createCategory(Category category) async {
    final currentUserId = _client.auth.currentUser?.id;
    final json = category.toJson();
    if (currentUserId != null) {
      json['user_id'] = currentUserId;
    }
    json.remove('id');
    json.remove('created_at');
    
    final response = await _client
        .from('categories')
        .insert(json)
        .select()
        .single();
    return Category.fromJson(response);
  }

  Future<Category> updateCategory(Category category) async {
    final json = category.toJson();
    json.remove('created_at');
    
    final response = await _client
        .from('categories')
        .update(json)
        .eq('id', category.id!)
        .select()
        .single();
    return Category.fromJson(response);
  }

  Future<void> deleteCategory(int categoryId) async {
    await _client.from('categories').delete().eq('id', categoryId);
  }
}
