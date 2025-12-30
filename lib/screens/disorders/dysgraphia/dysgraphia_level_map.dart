import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/navigation_helper.dart';

class DysgraphiaLevelMap extends StatelessWidget {
  const DysgraphiaLevelMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dysgraphia Learning Path'),
        backgroundColor: const Color(0xFFA78BFA),
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
            const Text('✍️', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Dysgraphia Learning Path',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dysgraphia/signs'),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}

