import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/disorder/disorder_select_screen.dart';
import '../screens/assessment/assessment_screen.dart';
import '../screens/dashboards/student_dashboard.dart';
import '../screens/dashboards/teacher_dashboard.dart';
import '../screens/dashboards/parent_dashboard.dart';
import '../screens/dashboards/admin_dashboard.dart';
import '../screens/recommendations/recommendations_screen.dart';
import '../screens/disorders/dyslexia/dyslexia_level_map.dart';
import '../screens/disorders/dyslexia/dyslexia_age_select.dart';
import '../screens/disorders/dyslexia/dyslexia_age_6_10.dart';
import '../screens/disorders/dyslexia/dyslexia_age_11_14.dart';
import '../screens/disorders/dyslexia/dyslexia_age_15_18.dart';
import '../screens/disorders/dyslexia/dyslexia_support.dart';
import '../screens/disorders/dysgraphia/dysgraphia_level_map.dart';
import '../screens/disorders/dysgraphia/dysgraphia_signs.dart';
import '../screens/disorders/dysgraphia/dysgraphia_menu.dart';
import '../screens/disorders/dysgraphia/dysgraphia_support.dart';
import '../screens/disorders/dyscalculia/dyscalculia_level_map.dart';
import '../screens/disorders/dyscalculia/dyscalculia_signs.dart';
import '../screens/disorders/dyscalculia/dyscalculia_menu.dart';
import '../screens/disorders/dyscalculia/dyscalculia_support.dart';
import '../screens/disorders/dyscalculia/dyscalculia_resources.dart';
import '../screens/disorders/autism/autism_level_map.dart';
import '../screens/disorders/autism/autism_signs.dart';
import '../screens/disorders/autism/autism_menu.dart';
import '../screens/disorders/autism/autism_support.dart';
import '../screens/disorders/autism/autism_resources.dart';
import '../screens/disorders/adhd/adhd_level_map.dart';
import '../screens/disorders/adhd/adhd_signs.dart';
import '../screens/disorders/adhd/adhd_menu.dart';
import '../screens/disorders/adhd/adhd_support.dart';
import '../screens/disorders/adhd/adhd_resources.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/disorder-select',
        builder: (context, state) => const DisorderSelectScreen(),
      ),
      GoRoute(
        path: '/assessment',
        builder: (context, state) => const AssessmentScreen(),
      ),
      GoRoute(
        path: '/recommendations',
        builder: (context, state) => const RecommendationsScreen(),
      ),
      // Dashboard routes
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboard(),
      ),
      GoRoute(
        path: '/teacher',
        builder: (context, state) => const TeacherDashboard(),
      ),
      GoRoute(
        path: '/parent',
        builder: (context, state) => const ParentDashboard(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
      // Dyslexia routes
      GoRoute(
        path: '/dyslexia',
        builder: (context, state) => const DyslexiaLevelMap(),
      ),
      GoRoute(
        path: '/dyslexia/age-select',
        builder: (context, state) => const DyslexiaAgeSelect(),
      ),
      GoRoute(
        path: '/dyslexia/age/6-10',
        builder: (context, state) => const DyslexiaAge6to10(),
      ),
      GoRoute(
        path: '/dyslexia/age/11-14',
        builder: (context, state) => const DyslexiaAge11to14(),
      ),
      GoRoute(
        path: '/dyslexia/age/15-18',
        builder: (context, state) => const DyslexiaAge15to18(),
      ),
      GoRoute(
        path: '/dyslexia/support',
        builder: (context, state) => const DyslexiaSupport(),
      ),
      // Dysgraphia routes
      GoRoute(
        path: '/dysgraphia',
        builder: (context, state) => const DysgraphiaLevelMap(),
      ),
      GoRoute(
        path: '/dysgraphia/signs',
        builder: (context, state) => const DysgraphiaSigns(),
      ),
      GoRoute(
        path: '/dysgraphia/menu',
        builder: (context, state) => const DysgraphiaMenu(),
      ),
      GoRoute(
        path: '/dysgraphia/support',
        builder: (context, state) => const DysgraphiaSupport(),
      ),
      // Dyscalculia routes
      GoRoute(
        path: '/dyscalculia',
        builder: (context, state) => const DyscalculiaLevelMap(),
      ),
      GoRoute(
        path: '/dyscalculia/signs',
        builder: (context, state) => const DyscalculiaSigns(),
      ),
      GoRoute(
        path: '/dyscalculia/menu',
        builder: (context, state) => const DyscalculiaMenu(),
      ),
      GoRoute(
        path: '/dyscalculia/support',
        builder: (context, state) => const DyscalculiaSupport(),
      ),
      GoRoute(
        path: '/dyscalculia/resources',
        builder: (context, state) => const DyscalculiaResources(),
      ),
      // Autism routes
      GoRoute(
        path: '/autism',
        builder: (context, state) => const AutismLevelMap(),
      ),
      GoRoute(
        path: '/autism/signs',
        builder: (context, state) => const AutismSigns(),
      ),
      GoRoute(
        path: '/autism/menu',
        builder: (context, state) => const AutismMenu(),
      ),
      GoRoute(
        path: '/autism/support',
        builder: (context, state) => const AutismSupport(),
      ),
      GoRoute(
        path: '/autism/resources',
        builder: (context, state) => const AutismResources(),
      ),
      // ADHD routes
      GoRoute(
        path: '/adhd',
        builder: (context, state) => const ADHDLevelMap(),
      ),
      GoRoute(
        path: '/adhd/signs',
        builder: (context, state) => const ADHDSigns(),
      ),
      GoRoute(
        path: '/adhd/menu',
        builder: (context, state) => const ADHDMenu(),
      ),
      GoRoute(
        path: '/adhd/support',
        builder: (context, state) => const ADHDSupport(),
      ),
      GoRoute(
        path: '/adhd/resources',
        builder: (context, state) => const ADHDResources(),
      ),
    ],
    redirect: (context, state) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final userRole = appProvider.userRole;
      final location = state.uri.path;

      // Protected routes
      if (location.startsWith('/student') || 
          location.startsWith('/teacher') || 
          location.startsWith('/parent') || 
          location.startsWith('/admin')) {
        if (userRole == null) {
          return '/login';
        }
        
        // Role-based redirect
        if (location.startsWith('/student') && userRole != 'student') {
          return '/$userRole';
        }
        if (location.startsWith('/teacher') && userRole != 'teacher') {
          return '/$userRole';
        }
        if (location.startsWith('/parent') && userRole != 'parent') {
          return '/$userRole';
        }
        if (location.startsWith('/admin') && userRole != 'admin') {
          return '/$userRole';
        }
      }

      return null;
    },
  );
}

