import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/navigation_helper.dart';

class AutismSigns extends StatelessWidget {
  const AutismSigns({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autism Signs'),
        backgroundColor: const Color(0xFF60A5FA),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => NavigationHelper.navigateToHome(context),
        ),
      ),
      body: const Center(
        child: Text('Autism Signs and Symptoms'),
      ),
    );
  }
}

