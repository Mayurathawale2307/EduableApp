import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/navigation_helper.dart';

class DyslexiaAgeSelect extends StatelessWidget {
  const DyslexiaAgeSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Age Group'),
        backgroundColor: const Color(0xFFFF6B9D),
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
            _AgeButton(
              label: 'Age 6-10',
              onTap: () => context.go('/dyslexia/age/6-10'),
            ),
            const SizedBox(height: 16),
            _AgeButton(
              label: 'Age 11-14',
              onTap: () => context.go('/dyslexia/age/11-14'),
            ),
            const SizedBox(height: 16),
            _AgeButton(
              label: 'Age 15-18',
              onTap: () => context.go('/dyslexia/age/15-18'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AgeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6B9D),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      ),
      child: Text(label),
    );
  }
}

