import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/navigation_helper.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final disability = appProvider.userDisability;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
        backgroundColor: const Color(0xFF7E8BFF),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => NavigationHelper.navigateToHome(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personalized Recommendations',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F1F2E),
              ),
            ),
            const SizedBox(height: 16),
            if (disability != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Based on your assessment, we recommend focusing on:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        disability,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7E8BFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (disability == 'Dyslexia') {
                  context.go('/dyslexia');
                } else if (disability == 'Dysgraphia') {
                  context.go('/dysgraphia');
                } else if (disability == 'Dyscalculia') {
                  context.go('/dyscalculia');
                } else if (disability == 'ADHD') {
                  context.go('/adhd');
                } else if (disability == 'Autism (ASD)') {
                  context.go('/autism');
                } else {
                  context.go('/disorder-select');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7E8BFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Start Learning Path'),
            ),
          ],
        ),
      ),
    );
  }
}

