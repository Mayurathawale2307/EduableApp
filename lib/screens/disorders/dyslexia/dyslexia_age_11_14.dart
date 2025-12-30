import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/navigation_helper.dart';

class DyslexiaAge11to14 extends StatelessWidget {
  const DyslexiaAge11to14({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dyslexia - Age 11-14'),
        backgroundColor: const Color(0xFFFF6B9D),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => NavigationHelper.navigateToHome(context),
        ),
      ),
      body: const Center(
        child: Text('Dyslexia Learning Content for Age 11-14'),
      ),
    );
  }
}

