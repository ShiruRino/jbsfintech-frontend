import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/providers.dart';
import '../features/auth/presentation/auth_listener.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class JbsFintechApp extends ConsumerWidget {
  const JbsFintechApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'jbsfintech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return AuthListener(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
