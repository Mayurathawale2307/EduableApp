import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/navigation_helper.dart';

class DyscalculiaLevelMap extends StatelessWidget {
  const DyscalculiaLevelMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dyscalculia Learning Path'),
        backgroundColor: const Color(0xFFFFB84D),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => NavigationHelper.navigateToHome(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔢', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Dyscalculia Learning Path',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dyscalculia/signs'),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}

