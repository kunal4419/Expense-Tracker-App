import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';
import 'auth_provider.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(supabaseClientProvider));
});

class CategoryState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;

  CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryNotifier(this._categoryRepository) : super(CategoryState()) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _categoryRepository.getCategories();
      state = state.copyWith(categories: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addCategory(String name, String color) async {
    state = state.copyWith(isLoading: true);
    try {
      final newCat = Category(name: name, color: color, isDefault: false);
      final created = await _categoryRepository.createCategory(newCat);
      state = state.copyWith(
        categories: [...state.categories, created],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> editCategory(Category category) async {
    state = state.copyWith(isLoading: true);
    try {
      final updated = await _categoryRepository.updateCategory(category);
      state = state.copyWith(
        categories: state.categories.map((c) => c.id == updated.id ? updated : c).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> removeCategory(int categoryId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _categoryRepository.deleteCategory(categoryId);
      state = state.copyWith(
        categories: state.categories.where((c) => c.id != categoryId).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  return CategoryNotifier(ref.watch(categoryRepositoryProvider));
});
