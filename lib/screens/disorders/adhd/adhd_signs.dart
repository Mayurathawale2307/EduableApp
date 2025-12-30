import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/navigation_helper.dart';

class ADHDSigns extends StatelessWidget {
  const ADHDSigns({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADHD Signs'),
        backgroundColor: const Color(0xFF34D399),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => NavigationHelper.navigateToHome(context),
        ),
      ),
      body: const Center(
        child: Text('ADHD Signs and Symptoms'),
      ),
    );
  }
}

