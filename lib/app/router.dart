import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_shell_scaffold.dart';
import '../features/accounts/presentation/account_detail_screen.dart';
import '../features/accounts/presentation/account_form_screen.dart';
import '../features/accounts/presentation/accounts_screen.dart';
import '../features/auth/domain/auth_state.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/categories/presentation/category_form_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/transactions/presentation/transaction_detail_screen.dart';
import '../features/transactions/presentation/transaction_form_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import '../features/auth/presentation/auth_controller.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authController = ref.watch(authControllerProvider.notifier);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: authController,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final path = state.uri.path;
      final isAuthRoute = path == '/login';
      final isSplash = path == '/splash';

      if (authState.status == AuthStatus.unknown) {
        return isSplash ? null : '/splash';
      }

      if (authState.status == AuthStatus.unauthenticated) {
        return isAuthRoute ? null : '/login';
      }

      if (authState.status == AuthStatus.authenticated &&
          (isAuthRoute || isSplash)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TransactionsScreen()),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const TransactionFormScreen(),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => TransactionDetailScreen(
                  transactionId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: ':id/edit',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => TransactionFormScreen(
                  transactionId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/accounts',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AccountsScreen()),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const AccountFormScreen(),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => AccountDetailScreen(
                  accountId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: ':id/edit',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => AccountFormScreen(
                  accountId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const CategoryFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) => CategoryFormScreen(
              categoryId: int.parse(state.pathParameters['id']!),
            ),
          ),
        ],
      ),
    ],
  );
});
