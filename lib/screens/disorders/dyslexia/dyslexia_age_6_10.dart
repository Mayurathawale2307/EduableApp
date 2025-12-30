import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/navigation_helper.dart';

class DyslexiaAge6to10 extends StatelessWidget {
  const DyslexiaAge6to10({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dyslexia - Age 6-10'),
        backgroundColor: const Color(0xFFFF6B9D),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => NavigationHelper.navigateToHome(context),
        ),
      ),
      body: const Center(
        child: Text('Dyslexia Learning Content for Age 6-10'),
      ),
    );
  }
}

