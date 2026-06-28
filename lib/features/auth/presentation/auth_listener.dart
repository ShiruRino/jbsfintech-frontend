import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/auth_state.dart';
import 'auth_controller.dart';

class AuthListener extends ConsumerStatefulWidget {
  const AuthListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AuthListener> createState() => _AuthListenerState();
}

class _AuthListenerState extends ConsumerState<AuthListener> {
  @override
  void initState() {
    super.initState();
    ref.listenManual<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.status == AuthStatus.authenticated &&
          next.status == AuthStatus.unauthenticated &&
          mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
