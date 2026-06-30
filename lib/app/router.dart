import 'package:expense/features/expenses/add_expense_screen.dart';
import 'package:expense/features/expenses/edit_expense_screen.dart';
import 'package:expense/features/expenses/expense_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../providers/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/home_shell.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/expenses/expense_list_screen.dart';
import 'package:expense/features/categories/category_screen.dart';
import 'package:expense/features/reports/report_screen.dart';
import 'package:expense/features/sales/sales_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wallet, size: 64, color: Colors.indigo),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class RouterListenable extends ChangeNotifier {
  RouterListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerListenableProvider = Provider<RouterListenable>((ref) {
  return RouterListenable(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = ref.watch(routerListenableProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: listenable,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return HomeShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) => const ExpenseListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddExpenseScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final expense = state.extra as Expense;
                  return EditExpenseScreen(expense: expense);
                },
              ),
              GoRoute(
                path: 'detail',
                builder: (context, state) {
                  final expense = state.extra as Expense;
                  return ExpenseDetailScreen(expense: expense);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/sales',
            builder: (context, state) => const SalesScreen(),
          ),
          GoRoute(
            path: '/categories',
            builder: (context, state) => const CategoryScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.user != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';

      if (isLoading) {
        if (isSplash) return null;
        return '/splash';
      }

      if (!isLoggedIn) {
        if (isLoggingIn) return null;
        return '/login';
      }

      if (isLoggedIn) {
        if (isLoggingIn || isSplash) {
          return '/';
        }
      }

      return null;
    },
  );
});
