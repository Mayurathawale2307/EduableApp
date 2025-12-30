import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class NavigationHelper {
  /// Navigates to home page or user dashboard based on login status
  static void navigateToHome(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final userRole = appProvider.userRole;
    final token = appProvider.token;

    // If user is logged in, navigate to their dashboard
    if (token != null && userRole != null) {
      switch (userRole) {
        case 'student':
          context.go('/student');
          break;
        case 'teacher':
          context.go('/teacher');
          break;
        case 'parent':
          context.go('/parent');
          break;
        case 'admin':
          context.go('/admin');
          break;
        default:
          context.go('/');
      }
    } else {
      // If not logged in, navigate to home page
      context.go('/');
    }
  }
}

