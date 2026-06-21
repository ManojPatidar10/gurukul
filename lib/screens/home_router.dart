import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/auth_state.dart';
import 'auth/login_screen.dart';
import 'teacher/teacher_home_screen.dart';
import 'parent/parent_home_screen.dart';

/// Decides what to show after launch: login, or the right role's home.
/// One Flutter codebase serves both the Teacher app and the Parent app —
/// simpler to build and ship than three separate apps, and the role is
/// already known from the `profiles` table the moment someone signs in.
class HomeRouter extends StatelessWidget {
  const HomeRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    if (auth.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (auth.profile == null) {
      return const LoginScreen();
    }

    switch (auth.profile!.role) {
      case UserRole.teacher:
        return const TeacherHomeScreen();
      case UserRole.parent:
        return const ParentHomeScreen();
      case UserRole.director:
        // Directors primarily use the web Command Center; mobile shows
        // the same parent-style read-only view scoped to their school.
        return const ParentHomeScreen();
    }
  }
}
