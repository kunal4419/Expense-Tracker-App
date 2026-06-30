import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
